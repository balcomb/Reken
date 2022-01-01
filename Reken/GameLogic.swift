//
//  GameLogic.swift
//  Reken
//
//  Created by Ben Balcomb on 1/1/22.
//

import Foundation

class GameLogic {

    private lazy var board = Board()
    private var activePlayer: Player = .blue
    private lazy var score: (blue: Int, orange: Int) = (0, 0)

    func addAnchor(at location: Point) -> Anchor? {
        let anchor = board.addAnchor(at: location, player: activePlayer)
        update(with: anchor)
        return anchor
    }

    private func update(with anchor: Anchor?) {
        guard let anchor = anchor else { return }
        switch activePlayer {
        case .blue: score.blue += anchor.score
        case .orange: score.orange += anchor.score
        }
        print(score)
        activePlayer = activePlayer.opponent
    }
}

extension GameLogic {

    enum Player: CaseIterable {
        case blue, orange

        var opponent: Player { Player.allCases.first { $0 != self }! }
    }
}
