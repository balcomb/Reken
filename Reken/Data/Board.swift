//
//  Board.swift
//  Reken
//
//  Created by Ben Balcomb on 12/31/21.
//

import Foundation

struct Board {

    static var gridSize: Int { 12 }

    private var nodes = Array(
        repeating: Array(repeating: Node(), count: Self.gridSize),
        count: Self.gridSize
    )

    var emptyLocations: [Point] {
        var emptyLocations = [Point]()
        for (x, column) in nodes.enumerated() {
            for (y, node) in column.enumerated() {
                if node.piece == nil { emptyLocations.append((x, y)) }
            }
        }
        return emptyLocations
    }

    var score: Score {
        var score: Score = (0, 0)
        let anchors = nodes.joined().compactMap { $0.piece as? Anchor }
        anchors.forEach {
            switch $0.player {
            case .blue: score.blue += $0.score
            case .orange: score.orange += $0.score
            }
        }
        return score
    }

    func getNode(at location: Point) -> Node? {
        nodes[location]
    }

    private func getAnchor(at location: Point) -> Anchor? {
        nodes[location]?.piece as? Anchor
    }

    mutating func addAnchor(at location: Point, player: GameLogic.Player) -> MoveResult? {
        guard nodeIsEmpty(at: location) else { return nil }
        var newAnchor = Anchor(location: location, player: player)
        var result: MoveResult = (newAnchor, [], [])
        Anchor.Diagonal.allCases.forEach {
            guard var captureCandidate = getAnchor(at: newAnchor.getLocation(for: $0)),
                  var pieceToUpdate = getAnchor(at: captureCandidate.getLocation(for: $0)),
                  captureCandidate.player == player.opponent,
                  pieceToUpdate.player == player
            else {
                return
            }
            captureCandidate.stems.forEach { removePiece(at: $0.location) }
            captureCandidate.stems = []
            captureCandidate.player = player
            updateNode(with: captureCandidate)
            pieceToUpdate = updateStems(for: pieceToUpdate)
            updateNode(with: pieceToUpdate)
            result.updatedAnchors.append(pieceToUpdate)
            result.capturedAnchors.append(captureCandidate)
        }
        newAnchor = updateStems(for: newAnchor)
        result.newPiece = newAnchor
        updateNode(with: newAnchor)
        return result
    }

    private mutating func removePiece(at location: Point) {
        guard var node = nodes[location] else { return }
        node.piece = nil
        nodes[location.x][location.y] = node
    }

    private mutating func updateStems(for anchor: Anchor) -> Anchor {
        var anchor = anchor
        Stem.Direction.allCases.forEach {
            let stem = Stem(anchor: anchor, direction: $0)
            if nodeIsEmpty(at: stem.location) {
                updateNode(with: stem)
                anchor.stems.append(stem)
            }
        }
        return anchor
    }

    func nodeIsEmpty(at location: Point) -> Bool {
        guard let node = nodes[location] else { return false }
        return node.piece == nil
    }

    private mutating func updateNode(with piece: Piece) {
        guard var node = nodes[piece.location] else { return }
        node.piece = piece
        nodes[piece.location.x][piece.location.y] = node
    }
}

extension Board {

    struct Node {
        var piece: Piece?
    }
}
