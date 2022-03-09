//
//  BoardView.swift
//  Reken
//
//  Created by Ben Balcomb on 12/14/21.
//

import UIKit
import Combine

class BoardView: UIView, EventSubscriber {

    lazy var cancellables = Set<AnyCancellable>()
    private var dataSource: GameDataSource!
    private lazy var cells = [Board.Position: CellView]()
    private lazy var pieces = [Board.Position: PieceView]()

    private lazy var confirmView: ConfirmView = {
        let confirmView = ConfirmView()
        superview?.addSubview(confirmView)
        subscribe(to: confirmView.actionPublisher) { [weak self] in
            self?.dataSource.handleConfirmAction($0)
        }
        return confirmView
    }()

    convenience init(dataSource: GameDataSource) {
        self.init()
        self.dataSource = dataSource
        makeCells()
        subscribe(to: dataSource.selectedPositionPublisher) { [weak self] in
            self?.handleSelectedPosition($0)
        }
        subscribe(to: dataSource.moveResultPublisher) { [weak self] moveResult in
            self?.update(with: moveResult)
        }
        subscribe(to: dataSource.gameUpdatePublisher) { [weak self] game in
            self?.handleUpdate(for: game)
        }
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
        subscribe(to: cell.tapPublisher) { [weak self] in
            self?.dataSource.handleSelectedPosition(position)
        }
        return cell
    }

    private func handleUpdate(for game: Game) {
        guard game.progress == .new else { return }
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5) {
            self.pieces.values.forEach { $0.alpha = 0 }
            self.confirmView.alpha = 0
        } completion: { _ in
            self.isUserInteractionEnabled = true
            self.pieces.removeAll()
        }
    }

    private func handleSelectedPosition(_ position: Board.Position?) {
        cells.values.forEach {
            if $0.isSelected { $0.isSelected = false }
        }
        guard let position = position, let cell = cells[position] else {
            confirmView.hide()
            return
        }
        cell.isSelected = true
        confirmView.show(for: cell, isAlignedLeft: position.x < Board.size / 2)
    }

    private func update(with moveResult: MoveResult) {
        addAnchor(moveResult.newAnchor)
        moveResult.updatedAnchors.capturedAnchors.forEach {
            resetStems(for: $0)
        }
        moveResult.updatedAnchors.capturingAnchors.forEach {
            updateStems(for: $0)
        }
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
                  let stemView = pieceView.stems[stem.direction]
            else {
                return
            }
            stemView.makeConstraints(positionView: stemCell)
        }
        UIView.animate(withDuration: 0.4) {
            self.layoutIfNeeded()
            pieceView.updateView(with: anchor)
        }
    }

    private func resetStems(for anchor: Anchor) {
        guard let pieceView = pieces[anchor.position] else { return }
        pieceView.resetStems()
        pieceView.updateView(with: anchor)
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
