//
//  ControlView.swift
//  Reken
//
//  Created by Ben Balcomb on 2/4/22.
//

import UIKit
import Combine

class ControlView: UIView, EventSubscriber {

    lazy var cancellables = Set<AnyCancellable>()
    private var dataSource: GameDataSource!

    private lazy var playAgainButton: UIButton = {
        let button = UIButton(
            type: .system,
            primaryAction: UIAction(handler: { [weak self] _ in self?.dataSource.startNewGame() })
        )
        button.alpha = 0
        button.backgroundColor = .gray
        button.setTitleColor(.white, for: .normal)
        let space = "      "
        button.setTitle(space + "Play Again" + space, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
        return button
    }()

    convenience init(dataSource: GameDataSource) {
        self.init()
        self.dataSource = dataSource
        addSubview(playAgainButton)
        playAgainButton.snp.makeConstraints { $0.center.equalToSuperview() }
        layoutIfNeeded()
        playAgainButton.layer.cornerRadius = playAgainButton.frame.size.height / 2
        subscribe(to: dataSource.gameUpdatePublisher) { [weak self] game in
            self?.handleUpdates(for: game)
        }
    }

    private func handleUpdates(for game: Game) {
        guard game.progress != .active else { return }
        let playAgainButtonAlpha: CGFloat = game.progress == .complete ? 1 : 0
        UIView.animate(withDuration: 0.5) {
            self.playAgainButton.alpha = playAgainButtonAlpha
        }
    }
}
