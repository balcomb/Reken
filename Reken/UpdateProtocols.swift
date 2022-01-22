//
//  UpdateProtocols.swift
//  Reken
//
//  Created by Ben Balcomb on 1/18/22.
//

import Foundation
import Combine

typealias EventPublisher<O> = AnyPublisher<O, Never>
typealias EventSubject<O> = PassthroughSubject<O, Never>

protocol BoardUpdater {
    var showConfirmPublisher: EventPublisher<Board.Position> { get }
    var moveResultPublisher: EventPublisher<MoveResult> { get }
}

protocol GameUpdater {
    var selectionPublisher: EventPublisher<Board.Position> { get }
    var confirmPublisher: EventPublisher<Board.Position> { get }
}

protocol ScoreUpdater {
    var gameStatePublisher: EventPublisher<GameLogic.State> { get }
}

protocol EventSubscriber: AnyObject {
    var cancellables: Set<AnyCancellable> { get set }
}

extension EventSubscriber {

    func subscribe<O>(to publisher: EventPublisher<O>, receiver: @escaping (O) -> Void) {
        publisher.sink { receiver($0) }.store(in: &cancellables)
    }
}
