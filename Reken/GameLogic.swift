//
//  GameLogic.swift
//  Reken
//
//  Created by Ben Balcomb on 1/1/22.
//

import Foundation
import Combine

typealias MoveResult = (newPiece: Anchor, updatedAnchors: [Anchor], capturedAnchors: [Anchor])
typealias Score = (blue: Int, orange: Int)

class GameLogic {

    private lazy var board = Board()
    private var state = State.initial

    var moveResultPublisher: AnyPublisher<MoveResult, Never> {
        moveResultSubject.eraseToAnyPublisher()
    }
    private lazy var moveResultSubject = PassthroughSubject<MoveResult, Never>()

    var statePublisher: AnyPublisher<State, Never> { stateSubject.eraseToAnyPublisher() }
    private lazy var stateSubject = PassthroughSubject<State, Never>()

    func handleMove(at location: Point, isAutoMove: Bool = false) {
        guard (state.activePlayer == .blue || isAutoMove),
              let result = board.addAnchor(at: location, player: state.activePlayer)
        else {
            return
        }
        state.activePlayer = state.activePlayer.opponent
        state.score = board.score
        moveResultSubject.send(result)
        stateSubject.send(state)
        guard result.newPiece.player == .blue else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { self.autoMove() }
    }

    private func autoMove() {
        let automaton = Automaton(player: state.activePlayer, board: board)
        guard let location = automaton.findMove() else { return }
        self.handleMove(at: location, isAutoMove: true)
    }
}

extension GameLogic {

    enum Player: CaseIterable {
        case blue, orange

        var opponent: Player { Player.allCases.first { $0 != self }! }
    }

    struct State {
        var activePlayer: GameLogic.Player
        var score: Score

        static var initial: State { State(activePlayer: .blue, score: (0, 0)) }
    }
}
