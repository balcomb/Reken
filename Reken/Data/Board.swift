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
    var isEmpty: Bool { pieces.isEmpty }
    var isFull: Bool { pieces.keys.count == Self.allPositions.count }
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

    func scoreDiff(for player: Game.Player) -> Int {
        let score = score
        switch player {
        case .blue: return score.blue - score.orange
        case .orange: return score.orange - score.blue
        }
    }

    func getPiece(at position: Position) -> Piece? {
        pieces[position]
    }

    func getAnchor(at position: Position) -> Anchor? {
        pieces[position] as? Anchor
    }

    mutating func addAnchor(at position: Position, player: Game.Player) -> MoveResult? {
        guard isOpen(at: position) else { return nil }
        var newAnchor = Anchor(position: position, player: player)
        let updatedAnchors = getUpdatedAnchors(for: newAnchor)
        configureAnchor(&newAnchor)
        return MoveResult(newAnchor, updatedAnchors)
    }

    private mutating func getUpdatedAnchors(for anchor: Anchor) -> UpdatedAnchors {
        var updatedAnchors = UpdatedAnchors([], [])
        Ordinal.allCases.forEach { ordinal in
            guard let capturePair = getCapturePair(for: anchor, with: ordinal) else { return }
            updatedAnchors.capturingAnchors.append(capturePair.capturingAnchor)
            updatedAnchors.capturedAnchors.append(capturePair.capturedAnchor)
        }
        return updatedAnchors
    }

    private mutating func getCapturePair(
        for anchor: Anchor,
        with ordinal: Ordinal
    ) -> (capturedAnchor: Anchor, capturingAnchor: Anchor)? {
        guard var capturedAnchor = getAnchor(at: anchor.getPosition(for: ordinal)),
              capturedAnchor.player == anchor.player.opponent,
              var capturingAnchor = getAnchor(at: capturedAnchor.getPosition(for: ordinal)),
              capturingAnchor.player == anchor.player
        else {
            return nil
        }
        updateCapturedAnchor(&capturedAnchor)
        configureAnchor(&capturingAnchor)
        return (capturedAnchor, capturingAnchor)
    }

    private mutating func updateCapturedAnchor(_ anchor: inout Anchor) {
        anchor.stems.forEach { pieces[$0.position] = nil }
        anchor.stems = []
        anchor.player = anchor.player.opponent
        updateBoard(with: anchor)
    }

    private mutating func configureAnchor(_ anchor: inout Anchor) {
        Cardinal.allCases.forEach {
            let stem = Stem(anchor: anchor, direction: $0)
            guard isOpen(at: stem.position) else { return }
            updateBoard(with: stem)
            anchor.stems.append(stem)
        }
        updateBoard(with: anchor)
    }

    func isOpen(at position: Position) -> Bool {
        position.isValid && pieces[position] == nil
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

        func getPosition<D: Direction>(for direction: D, distance: Int = 1) -> Board.Position {
            var convertedDelta = direction.positionDelta
            convertedDelta.x *= distance
            convertedDelta.y *= distance
            return self + convertedDelta
        }

        static func +(lhs: Position, rhs: Position) -> Position {
            Position(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
        }

        static var zero: Position { Position(x: 0, y: 0) }
    }
}
