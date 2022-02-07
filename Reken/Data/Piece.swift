//
//  Piece.swift
//  Reken
//
//  Created by Ben Balcomb on 12/18/21.
//

import Foundation

protocol Piece {
    var position: Board.Position { get }
}

extension Piece {

    func getPosition(for diagonal: Diagonal) -> Board.Position {
        let shift: (x: Int, y: Int)
        switch diagonal {
        case .northwest: shift = (-1, -1)
        case .northeast: shift = (1, -1)
        case .southeast: shift = (1, 1)
        case .southwest: shift = (-1, 1)
        }
        return Board.Position(x: position.x + shift.x, y: position.y + shift.y)
    }
}

struct Anchor: Piece {
    let position: Board.Position
    var player: Game.Player
    var stems: [Stem] = []
    var score: Int { Stem.Direction.allCases.count - stems.count }
}

struct Stem: Piece {
    let anchor: Anchor
    let direction: Direction

    var position: Board.Position {
        var position = anchor.position
        switch direction {
        case .north: position.y -= 1
        case .south: position.y += 1
        case .east: position.x += 1
        case .west: position.x -= 1
        }
        return position
    }

    enum Direction: CaseIterable {
        case north, south, east, west
    }
}

enum Diagonal: CaseIterable {
    case northwest, northeast, southeast, southwest
}
