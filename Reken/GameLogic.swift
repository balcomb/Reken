//
//  GameLogic.swift
//  Reken
//
//  Created by Ben Balcomb on 1/1/22.
//

import Foundation
import Combine

protocol GameDataSource {
    var selectedPositionPublisher: EventPublisher<Board.Position?> { get }
    var gameUpdatePublisher: EventPublisher<Game> { get }
    var moveResultPublisher: EventPublisher<MoveResult> { get }
    var settingsPublisher: EventPublisher<Settings> { get }
    var settingsIsVisiblePublisher: EventPublisher<Bool> { get }
    var settingsErrorPublisher: EventPublisher<Void> { get }
    func startNewGame()
    func handleSelectedPosition(_ position: Board.Position)
    func handleConfirmAction(_ action: GameLogic.ConfirmAction)
    func handleSettingsRequest()
    func updateSettings<O: SettingsOption>(option: O)
}

class GameLogic: GameDataSource {

    lazy var selectedPositionPublisher = selectedPositionSubject.eraseToAnyPublisher()
    lazy var gameUpdatePublisher = gameUpdateSubject.eraseToAnyPublisher()
    lazy var moveResultPublisher = moveResultSubject.eraseToAnyPublisher()
    lazy var settingsPublisher = settingsSubject.eraseToAnyPublisher()
    lazy var settingsErrorPublisher = settingsErrorSubject.eraseToAnyPublisher()
    lazy var settingsIsVisiblePublisher = settingsIsVisibleSubject.eraseToAnyPublisher()

    private lazy var selectedPositionSubject = EventSubject<Board.Position?>()
    private lazy var moveResultSubject = EventSubject<MoveResult>()
    private lazy var gameUpdateSubject = EventSubject<Game>()
    private lazy var settingsSubject = EventSubject<Settings>()
    private lazy var settingsErrorSubject = EventSubject<Void>()
    private lazy var settingsIsVisibleSubject = EventSubject<Bool>()

    private var game: Game!
    private var settings: Settings = .stored ?? .standard

    private var selectedPosition: Board.Position? {
        didSet {
            selectedPositionSubject.send(selectedPosition)
        }
    }

    private var activePlayerIsHuman: Bool {
        settings.gameType == .twoPlayer || game.activePlayer == .blue
    }

    // MARK: data source methods

    func handleSelectedPosition(_ position: Board.Position) {
        guard position != selectedPosition &&
                activePlayerIsHuman &&
                game.board.isOpen(at: position)
        else {
            return
        }
        selectedPosition = position
    }

    func handleConfirmAction(_ action: GameLogic.ConfirmAction) {
        if action == .confirm { handleMove(at: selectedPosition) }
        selectedPosition = nil
    }

    func startNewGame() {
        game = Game()
        selectedPosition = nil
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

    // MARK: private methods

    private func handleMove(at position: Board.Position?) {
        guard let position = position,
              let result = game.board.addAnchor(at: position, player: game.activePlayer)
        else {
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

extension GameLogic {

    enum ConfirmAction {
        case confirm, reject
    }
}
