//
//  BoardView.swift
//  Reken
//
//  Created by Ben Balcomb on 12/14/21.
//

import UIKit
import Combine

class BoardView: UIView, EventSubscriber, GameUpdater {

    lazy var cancellables = Set<AnyCancellable>()

    var selectionPublisher: EventPublisher<Point> { selectionSubject.eraseToAnyPublisher() }
    private lazy var selectionSubject = EventSubject<Point>()

    var confirmPublisher: EventPublisher<Point> { confirmSubject.eraseToAnyPublisher() }
    private lazy var confirmSubject = EventSubject<Point>()

    private var size: Int!
    private var selectedLocation: Point?
    private lazy var cells = [[CellView]]()
    private lazy var pieces: [[UIView]] = Array(
        repeating: Array(repeating: UIView(), count: Board.gridSize),
        count: Board.gridSize
    )
    private lazy var confirmView: ConfirmView = {
        let confirmView = ConfirmView()
        superview?.addSubview(confirmView)
        subscribe(to: confirmView.actionPublisher) { [weak self] in self?.handleConfirmAction($0) }
        return confirmView
    }()

    convenience init(size: Int) {
        self.init()
        self.size = size
        makeCells()
    }

    func addUpdater(_ updater: BoardUpdater) {
        subscribe(to: updater.showConfirmPublisher) { [weak self] location in
            self?.showConfirm(at: location)
        }
        subscribe(to: updater.moveResultPublisher) { [weak self] moveResult in
            self?.update(with: moveResult)
        }
    }

    private func showConfirm(at location: Point) {
        guard let cell = cells[location] else { return }
        cell.setSelected(true)
        if let currentLocation = selectedLocation { cells[currentLocation]?.setSelected(false) }
        selectedLocation = location
        confirmView.show(for: cell, isAlignedLeft: location.x < self.size / 2)
    }

    private func update(with moveResult: MoveResult) {
        addAnchor(moveResult.newPiece)
        moveResult.capturedAnchors.forEach {
            resetStems(for: $0)
        }
        moveResult.updatedAnchors.forEach {
            updateStems(for: $0)
        }
    }

    private func handleConfirmAction(_ action: ConfirmView.Action) {
        guard let location = selectedLocation else { return }
        cells[location]?.setSelected(false)
        selectedLocation = nil
        if action == .confirm { confirmSubject.send(location) }
    }

    private func addAnchor(_ anchor: Anchor) {
        guard let cell = cells[anchor.location] else { return }
        let pieceView = PieceView(anchor: anchor, cellSize: cell.frame.width)
        pieces[anchor.location.x][anchor.location.y] = pieceView
        addSubview(pieceView)
        pieceView.snp.makeConstraints { make in
            make.center.equalTo(cell)
        }
        layoutIfNeeded()
        updateStems(for: anchor)
    }

    private func updateStems(for anchor: Anchor) {
        guard let pieceView = pieces[anchor.location] as? PieceView else { return }
        anchor.stems.forEach { stem in
            guard let stemCell = cells[stem.location],
                  let stemView = pieceView.stems.first(where: { $0.direction == stem.direction })
            else {
                return
            }
            stemView.makeConstraints(positionView: stemCell)
        }
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
            pieceView.updateView(with: anchor)
        }
    }

    private func resetStems(for anchor: Anchor) {
        guard let pieceView = pieces[anchor.location] as? PieceView else { return }
        pieceView.resetStems()
        pieceView.updateView(with: anchor)
    }

    private func makeCells() {

        var prevCell: CellView?

        for x in 0 ..< size {
            cells.append([])

            for y in 0 ..< size {
                let cell = CellView()
                addSubview(cell)
                cells[x].append(cell)
                setUpPublisher(cell: cell, location: (x, y))
                makeConstraints(for: cell, y: y, prevCell: prevCell)
                prevCell = cell
            }
        }
    }

    private func setUpPublisher(cell: CellView, location: Point) {
        cell.tapPublisher.sink { [weak self] in
            self?.handleTap(cell: cell, location: location)
        }.store(in: &cancellables)
    }

    private func handleTap(cell: CellView, location: Point) {
        selectionSubject.send(location)
    }

    private func makeConstraints(for cell: CellView, y: Int, prevCell: CellView?) {

        cell.snp.makeConstraints { make in
            if let prevCell = prevCell {
                if y == 0 {
                    make.left.equalTo(prevCell.snp.right)
                    make.top.equalToSuperview()
                } else {
                    make.left.equalTo(prevCell)
                    make.top.equalTo(prevCell.snp.bottom)
                }
            } else {
                make.left.top.equalToSuperview()
            }

            make.width.equalToSuperview().dividedBy(size)
            make.height.equalTo(cell.snp.width)
        }
    }
}
