//
//  GameViewController.swift
//  Reken
//
//  Created by Ben Balcomb on 11/27/21.
//

import UIKit
import SnapKit
import Combine

class GameViewController: UIViewController {

    private lazy var gameLogic = GameLogic()
    private lazy var scoreboard = ScoreboardView(state: .initial)
    private lazy var grid = GridView(size: Board.gridSize)
    private lazy var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        view.addSubview(grid)
        view.addSubview(scoreboard)
        makeConstraints()
        setUpPublishers()
    }

    private func setUpPublishers() {
        subscribe(to: grid.tapPublisher) { [weak self] location in
            self?.gameLogic.handleMove(at: location)
        }
        subscribe(to: gameLogic.moveResultPublisher) { [weak self] moveResult in
            self?.grid.update(with: moveResult)
        }
        subscribe(to: gameLogic.statePublisher) { [weak self] in
            self?.scoreboard.setState($0)
        }
    }

    private func subscribe<P: Publisher>(
        to publisher: P,
        receiver: @escaping (P.Output) -> Void
    ) {
        guard let publisher = publisher as? AnyPublisher<P.Output, Never> else { return }
        publisher.sink { receiver($0) }.store(in: &cancellables)
    }

    private func makeConstraints() {
        scoreboard.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(grid.snp.top).offset(-20)
        }
        grid.snp.makeConstraints { make in
            make.height.equalTo(grid.snp.width)
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(9)
        }
    }
}
