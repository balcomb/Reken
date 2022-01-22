//
//  Board.swift
//  Reken
//
//  Created by Ben Balcomb on 12/31/21.
//

import Foundation

struct Board {

    static var size: Int { 12 }
    private static let baseIndex = 0

    static let allPositions: [Position] = {
        let indexValues = Array(baseIndex ..< size)
        return Array(
            indexValues.map { x in
                indexValues.map { y in
                    Position(x: x, y: y)
                }
            }.joined()
        )
    }()

    private var pieces = [Position: Piece]()
    var openPositions: [Position] { Self.allPositions.filter { pieces[$0] == nil } }

    var score: Score {
        pieces.values.compactMap {
            $0 as? Anchor
        }.reduce(into: Score(0, 0)) { score, anchor in
            switch anchor.player {
            case .blue: score.blue += anchor.score
            case .orange: score.orange += anchor.score
            }
        }
    }

    func getPiece(at position: Position) -> Piece? {
        pieces[position]
    }

    func getAnchor(at position: Position) -> Anchor? {
        pieces[position] as? Anchor
    }

    mutating func addAnchor(at position: Position, player: GameLogic.Player) -> MoveResult? {
        guard isOpen(at: position) else { return nil }
        var newAnchor = Anchor(position: position, player: player)
        var result: MoveResult = (newAnchor, [], [])
        Anchor.Diagonal.allCases.forEach {
            guard var captureCandidate = getAnchor(at: newAnchor.getPosition(for: $0)),
                  var pieceToUpdate = getAnchor(at: captureCandidate.getPosition(for: $0)),
                  captureCandidate.player == player.opponent,
                  pieceToUpdate.player == player
            else {
                return
            }
            captureCandidate.stems.forEach { pieces[$0.position] = nil }
            captureCandidate.stems = []
            captureCandidate.player = player
            updateBoard(with: captureCandidate)
            pieceToUpdate = updateStems(for: pieceToUpdate)
            updateBoard(with: pieceToUpdate)
            result.updatedAnchors.append(pieceToUpdate)
            result.capturedAnchors.append(captureCandidate)
        }
        newAnchor = updateStems(for: newAnchor)
        result.newPiece = newAnchor
        updateBoard(with: newAnchor)
        return result
    }

    private mutating func updateStems(for anchor: Anchor) -> Anchor {
        var anchor = anchor
        Stem.Direction.allCases.forEach {
            let stem = Stem(anchor: anchor, direction: $0)
            guard isOpen(at: stem.position) else { return }
            updateBoard(with: stem)
            anchor.stems.append(stem)
        }
        return anchor
    }

    func isOpen(at position: Position) -> Bool {
        guard position.isValid else { return false }
        return pieces[position] == nil
    }

    private mutating func updateBoard(with piece: Piece) {
        pieces[piece.position] = piece
    }
}

extension Board {

    struct Position: Hashable {
        var x: Int
        var y: Int

        var isValid: Bool {
            let isValid: (Int) -> Bool = { $0 >= Board.baseIndex && $0 < Board.size }
            return isValid(x) && isValid(y)
        }

        var selfIfValid: Position? { isValid ? self : nil }
    }
}
