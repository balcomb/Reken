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
    var settingsPublisher: EventPublisher<Settings> { get }
    var settingsIsVisiblePublisher: EventPublisher<Bool> { get }
    var settingsErrorPublisher: EventPublisher<Void> { get }
    func isValidSelection(at position: Board.Position) -> Bool
    func handleConfirmedSelection(at position: Board.Position)
    func startNewGame()
    func handleSettingsRequest()
    func updateSettings<O: SettingsOption>(option: O)
}

extension GameLogic: GameDataSource {

    var gameUpdatePublisher: EventPublisher<Game> { gameUpdateSubject.eraseToAnyPublisher() }
    var moveResultPublisher: EventPublisher<MoveResult> { moveResultSubject.eraseToAnyPublisher() }
    var settingsPublisher: EventPublisher<Settings> { settingsSubject.eraseToAnyPublisher() }
    var settingsErrorPublisher: EventPublisher<Void> { settingsErrorSubject.eraseToAnyPublisher() }
    var settingsIsVisiblePublisher: EventPublisher<Bool> {
        settingsIsVisibleSubject.eraseToAnyPublisher()
    }

    func isValidSelection(at position: Board.Position) -> Bool {
        activePlayerIsHuman && game.board.isOpen(at: position)
    }

    func handleConfirmedSelection(at position: Board.Position) {
        handleMove(at: position)
    }

    func startNewGame() {
        game = Game()
        gameUpdateSubject.send(game)
        settingsIsVisibleSubject.send(false)
    }

    func handleSettingsRequest() {
        settingsSubject.send(settings)
        settingsIsVisibleSubject.send(true)
    }

    func updateSettings<O: SettingsOption>(option: O) {
        guard let updatedSettings = settings.getUpdated(with: option) else { return }
        guard updatedSettings.store() else {
            settingsErrorSubject.send()
            return
        }
        settings = updatedSettings
        settingsSubject.send(updatedSettings)
    }
}

class GameLogic {

    private var game: Game!
    private var settings: Settings = .stored ?? .standard
    private lazy var moveResultSubject = EventSubject<MoveResult>()
    private lazy var gameUpdateSubject = EventSubject<Game>()
    private lazy var settingsSubject = EventSubject<Settings>()
    private lazy var settingsErrorSubject = EventSubject<Void>()
    private lazy var settingsIsVisibleSubject = EventSubject<Bool>()

    private var activePlayerIsHuman: Bool {
        settings.gameType == .twoPlayer || game.activePlayer == .blue
    }

    private func handleMove(at position: Board.Position) {
        guard let result = game.board.addAnchor(at: position, player: game.activePlayer) else {
            return
        }
        game.activePlayer = game.activePlayer.opponent
        moveResultSubject.send(result)
        gameUpdateSubject.send(game)
        guard !activePlayerIsHuman else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { self.autoMove() }
    }

    private func autoMove() {
        let automaton = Automaton(
            player: game.activePlayer,
            board: game.board,
            skillLevel: settings.skillLevel
        )
        guard let position = automaton.findMove() else { return }
        handleMove(at: position)
    }
}
