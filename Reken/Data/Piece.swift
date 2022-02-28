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

    func getPosition<D: Direction>(for direction: D) -> Board.Position {
        position.getPosition(for: direction)
    }
}

struct Anchor: Piece {
    let position: Board.Position
    var player: Game.Player
    var stems: [Stem] = []
    var score: Int { Cardinal.allCases.count - stems.count }
}

struct Stem: Piece {
    let anchor: Anchor
    let direction: Cardinal

    var position: Board.Position {
        anchor.getPosition(for: direction)
    }
}
