//
//  GameLogic.swift
//  Reken
//
//  Created by Ben Balcomb on 1/1/22.
//

import Foundation
import Combine

protocol GameDataSource {
    var gameUpdatePublisher: EventPublisher<Game> { get }
    var moveResultPublisher: EventPublisher<MoveResult> { get }
    func isValidSelection(at position: Board.Position) -> Bool
    func handleConfirmedSelection(at position: Board.Position)
    func startNewGame()
}

extension GameLogic: GameDataSource {

    var gameUpdatePublisher: EventPublisher<Game> { gameUpdateSubject.eraseToAnyPublisher() }
    var moveResultPublisher: EventPublisher<MoveResult> { moveResultSubject.eraseToAnyPublisher() }

    func isValidSelection(at position: Board.Position) -> Bool {
        game.activePlayer == .blue && game.board.isOpen(at: position)
    }

    func handleConfirmedSelection(at position: Board.Position) {
        handleMove(at: position)
    }

    func startNewGame() {
        game = Game()
        gameUpdateSubject.send(game)
    }
}

class GameLogic {

    private var game: Game!
    private lazy var moveResultSubject = EventSubject<MoveResult>()
    private lazy var gameUpdateSubject = EventSubject<Game>()

    private func handleMove(at position: Board.Position, isAutoMove: Bool = false) {
        guard (game.activePlayer == .blue || isAutoMove),
              let result = game.board.addAnchor(at: position, player: game.activePlayer)
        else {
            return
        }
        game.activePlayer = game.activePlayer.opponent
        moveResultSubject.send(result)
        gameUpdateSubject.send(game)
        guard result.newAnchor.player == .blue else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { self.autoMove() }
    }

    private func autoMove() {
        let automaton = Automaton(player: game.activePlayer, board: game.board)
        guard let position = automaton.findMove() else { return }
        handleMove(at: position, isAutoMove: true)
    }
}
