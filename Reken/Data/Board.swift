//
//  Board.swift
//  Reken
//
//  Created by Ben Balcomb on 12/31/21.
//

import Foundation

struct Board {

    static var gridSize: Int { 12 }

    private lazy var nodes = Array(
        repeating: Array(repeating: Node(), count: Self.gridSize),
        count: Self.gridSize
    )

    mutating func addAnchor(at location: Point) -> Anchor? {
        guard nodeIsEmpty(at: location) else { return nil }
        var anchor = Anchor(location: location)
        updateNode(with: anchor)
        Stem.Direction.allCases.forEach {
            let stem = Stem(anchor: anchor, direction: $0)
            if nodeIsEmpty(at: stem.location) {
                updateNode(with: stem)
                anchor.stems.append(stem)
            }
        }
        return anchor
    }

    private mutating func nodeIsEmpty(at location: Point) -> Bool {
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
