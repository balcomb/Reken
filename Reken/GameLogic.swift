//
//  GameLogic.swift
//  Reken
//
//  Created by Ben Balcomb on 1/1/22.
//

import Foundation

typealias MoveResult = (newPiece: Anchor, updatedAnchors: [Anchor], capturedAnchors: [Anchor])
typealias Score = (blue: Int, orange: Int)

class GameLogic {

    private lazy var board = Board()
    private var activePlayer: Player = .blue
    var score: Score { board.score }

    func addAnchor(at location: Point) -> MoveResult? {
        guard let result = board.addAnchor(at: location, player: activePlayer) else { return nil }
        print(score)
        activePlayer = activePlayer.opponent
        return result
    }

    func autoMove() -> Point? {
        board.autoMove(player: self.activePlayer)
    }
}

extension GameLogic {

    enum Player: CaseIterable {
        case blue, orange

        var opponent: Player { Player.allCases.first { $0 != self }! }
    }
}
