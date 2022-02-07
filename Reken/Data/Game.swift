//
//  Game.swift
//  Reken
//
//  Created by Ben Balcomb on 2/5/22.
//

import Foundation

typealias MoveResult = (newAnchor: Anchor, updatedAnchors: UpdatedAnchors)
typealias UpdatedAnchors = (capturingAnchors: [Anchor], capturedAnchors: [Anchor])
typealias Score = (blue: Int, orange: Int)

struct Game {
    var activePlayer = Player.blue
    var board = Board()
    var score: Score { board.score }

    var progress: Progress {
        if board.isEmpty { return .new }
        if board.isFull { return .complete }
        return .active
    }

    enum Player: CaseIterable {
        case blue, orange

        var opponent: Player { Player.allCases.first { $0 != self }! }
    }

    enum Progress {
        case new
        case active
        case complete
    }
}
