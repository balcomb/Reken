//
//  ScoreView.swift
//  Reken
//
//  Created by Ben Balcomb on 1/15/22.
//

import UIKit
import Combine

class ScoreView: UIView, EventSubscriber {

    lazy var cancellables = Set<AnyCancellable>()

    private var views: [UIView] { [blueLabel, orangeLabel, winLabel, separator, indicator] }
    private lazy var blueLabel = makeScoreLabel()
    private lazy var orangeLabel = makeScoreLabel()
    private lazy var winLabel = makeScoreLabel(fontSize: 18)
    private lazy var separator = UIView(color: .lightGray)
    private lazy var indicator = UIView(color: .darkGray)

    convenience init(dataSource: GameDataSource) {
        self.init()
        views.forEach { addSubview($0) }
        makeConstraints()
        subscribe(to: dataSource.gameUpdatePublisher) { [weak self] in self?.setGameState($0) }
    }

    private func setGameState(_ game: Game) {
        blueLabel.attributedText = makeAttributedText(with: game, for: .blue)
        orangeLabel.attributedText = makeAttributedText(with: game, for: .orange)
        layoutIfNeeded()
        switch game.progress {
        case .new: renderNewGame(game)
        case .active: setActivePlayer(game.activePlayer)
        case .complete: renderWinLabel(with: game.score)
        }
    }

    private func setActivePlayer(_ player: Game.Player, animated: Bool = true) {
        makeIndicatorConstraints(for: player)
        guard animated else { return }
        UIView.animate(withDuration: 0.3) { self.layoutIfNeeded() }
    }

    private func renderNewGame(_ game: Game) {
        indicator.isHidden = false
        winLabel.alpha = 0
        winLabel.snp.remakeConstraints { $0.center.equalTo(separator) }
        setActivePlayer(game.activePlayer, animated: false)
    }

    private func renderWinLabel(with score: Score) {
        indicator.isHidden = true
        winLabel.attributedText = makeGameOverText(for: score)
        layoutIfNeeded()
        winLabel.snp.remakeConstraints { make in
            make.centerX.equalTo(separator)
            make.bottom.equalTo(separator.snp.top).offset(-8)
        }
        UIView.animate(withDuration: 0.5) {
            self.winLabel.alpha = 1
            self.layoutIfNeeded()
        }
    }

    private func makeGameOverText(for score: Score) -> NSAttributedString {
        let scoreDiff = score.blue - score.orange
        var symbol = "\u{2605}"
        let space = "  "
        let symbolColor: UIColor
        var text = " Wins!"
        if scoreDiff > 0 {
            text = "Blue" + text
            symbolColor = UIColor(for: .blue)
        } else if scoreDiff < 0 {
            text = "Orange" + text
            symbolColor = UIColor(for: .orange)
        } else {
            text = "It's a Tie!"
            symbol = "\u{2261}"
            symbolColor = .gray
        }
        let components = [symbol, space, text, space, symbol]
        let attributedText = NSMutableAttributedString()
        components.forEach {
            var attributes: [NSAttributedString.Key : Any]?
            if $0 == symbol { attributes = [.foregroundColor: symbolColor] }
            attributedText.append(NSAttributedString(string: $0, attributes: attributes))
        }
        return attributedText
    }

    private func makeAttributedText(
        with game: Game,
        for player: Game.Player
    ) -> NSAttributedString {
        let score = player == .blue ? game.score.blue : game.score.orange
        let color = UIColor(for: player)
        let circle = "\u{25CF}"
        var components = [circle, "  ", String(score)]
        if player == .orange { components.reverse() }
        let attributedText = NSMutableAttributedString()
        components.forEach {
            var attributes: [NSAttributedString.Key : Any]?
            if $0 == circle { attributes = [.foregroundColor: color] }
            attributedText.append(NSAttributedString(string: $0, attributes: attributes))
        }
        return attributedText
    }

    private func makeConstraints() {
        snp.makeConstraints { make in
            make.bottom.equalTo(indicator)
        }
        separator.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(blueLabel)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        let labelHorizontalOffset: CGFloat = 20
        blueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(separator)
            make.trailing.equalTo(separator.snp.leading).offset(-labelHorizontalOffset)
        }
        orangeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(separator)
            make.leading.equalTo(separator.snp.trailing).offset(labelHorizontalOffset)
        }
    }

    private func makeIndicatorConstraints(for activePlayer: Game.Player) {
        let height: CGFloat = 4
        indicator.layer.cornerRadius = height / 2
        indicator.snp.remakeConstraints { make in
            make.height.equalTo(height)
            make.left.right.equalTo(activePlayer == .blue ? blueLabel : orangeLabel)
            make.top.equalTo(separator.snp.bottom).offset(5)
        }
    }

    private func makeScoreLabel(fontSize: CGFloat = 28) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        label.textColor = .white
        return label
    }
}
