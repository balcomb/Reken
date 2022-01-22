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

    var selectionPublisher: EventPublisher<Board.Position> {
        selectionSubject.eraseToAnyPublisher()
    }
    private lazy var selectionSubject = EventSubject<Board.Position>()

    var confirmPublisher: EventPublisher<Board.Position> { confirmSubject.eraseToAnyPublisher() }
    private lazy var confirmSubject = EventSubject<Board.Position>()

    private var selectedPosition: Board.Position?
    private lazy var cells = [Board.Position: CellView]()
    private lazy var pieces = [Board.Position: PieceView]()

    private lazy var confirmView: ConfirmView = {
        let confirmView = ConfirmView()
        superview?.addSubview(confirmView)
        subscribe(to: confirmView.actionPublisher) { [weak self] in self?.handleConfirmAction($0) }
        return confirmView
    }()

    override func didMoveToSuperview() {
        makeCells()
    }

    private func makeCells() {
        guard cells.isEmpty else { return }
        var previousCell: CellView?
        Board.allPositions.forEach { position in
            previousCell = makeCell(at: position, with: previousCell)
        }
    }

    private func makeCell(at position: Board.Position, with previousCell: CellView?) -> CellView {
        let cell = CellView()
        cells[position] = cell
        addSubview(cell)
        makeConstraints(for: cell, at: position, with: previousCell)
        subscribe(to: cell.tapPublisher) { [weak self] in self?.handleTap(at: position) }
        return cell
    }

    func addUpdater(_ updater: BoardUpdater) {
        subscribe(to: updater.showConfirmPublisher) { [weak self] position in
            self?.showConfirm(at: position)
        }
        subscribe(to: updater.moveResultPublisher) { [weak self] moveResult in
            self?.update(with: moveResult)
        }
    }

    private func showConfirm(at position: Board.Position) {
        guard let cell = cells[position] else { return }
        cell.setSelected(true)
        if let currentPosition = selectedPosition { cells[currentPosition]?.setSelected(false) }
        selectedPosition = position
        confirmView.show(for: cell, isAlignedLeft: position.x < Board.size / 2)
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
        guard let position = selectedPosition else { return }
        cells[position]?.setSelected(false)
        selectedPosition = nil
        if action == .confirm { confirmSubject.send(position) }
    }

    private func addAnchor(_ anchor: Anchor) {
        guard let cell = cells[anchor.position] else { return }
        let pieceView = PieceView(anchor: anchor, cellSize: cell.frame.width)
        pieces[anchor.position] = pieceView
        addSubview(pieceView)
        pieceView.snp.makeConstraints { $0.center.equalTo(cell) }
        layoutIfNeeded()
        updateStems(for: anchor)
    }

    private func updateStems(for anchor: Anchor) {
        guard let pieceView = pieces[anchor.position] else { return }
        anchor.stems.forEach { stem in
            guard let stemCell = cells[stem.position],
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
        guard let pieceView = pieces[anchor.position] else { return }
        pieceView.resetStems()
        pieceView.updateView(with: anchor)
    }

    private func handleTap(at position: Board.Position) {
        selectionSubject.send(position)
    }

    private func makeConstraints(
        for cell: CellView,
        at position: Board.Position,
        with previousCell: CellView?
    ) {
        cell.snp.makeConstraints { make in
            if let previousCell = previousCell {
                if position.y == 0 {
                    make.top.equalToSuperview()
                    make.left.equalTo(previousCell.snp.right)
                } else {
                    make.top.equalTo(previousCell.snp.bottom)
                    make.left.equalTo(previousCell)
                }
            } else {
                make.top.left.equalToSuperview()
            }

            make.width.equalToSuperview().dividedBy(Board.size)
            make.height.equalTo(cell.snp.width)
        }
    }
}
