//
//  ScoreboardView.swift
//  Reken
//
//  Created by Ben Balcomb on 1/15/22.
//

import UIKit

class ScoreboardView: UIView {

    private var views: [UIView] { [blueLabel, orangeLabel, separator, indicator] }
    private lazy var blueLabel = makeScoreLabel(for: .blue)
    private lazy var orangeLabel = makeScoreLabel(for: .orange)
    private lazy var separator = UIView(color: .lightGray)
    private lazy var indicator = UIView(color: .darkGray)

    convenience init(state: GameLogic.State) {
        self.init()
        views.forEach { addSubview($0) }
        setState(state)
        makeConstraints()
    }

    func setState(_ state: GameLogic.State) {
        blueLabel.attributedText = makeAttributedText(with: state, for: .blue)
        orangeLabel.attributedText = makeAttributedText(with: state, for: .orange)
        layoutIfNeeded()
        makeIndicatorConstraints(for: state.activePlayer)
        UIView.animate(withDuration: 0.3) { self.layoutIfNeeded() }
    }

    private func makeAttributedText(
        with state: GameLogic.State,
        for player: GameLogic.Player
    ) -> NSAttributedString {
        let score = player == .blue ? state.score.blue : state.score.orange
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

    private func makeIndicatorConstraints(for activePlayer: GameLogic.Player) {
        let height: CGFloat = 4
        indicator.layer.cornerRadius = height / 2
        indicator.snp.remakeConstraints { make in
            make.height.equalTo(height)
            make.left.right.equalTo(activePlayer == .blue ? blueLabel : orangeLabel)
            make.top.equalTo(separator.snp.bottom).offset(5)
        }
    }

    private func makeScoreLabel(for player: GameLogic.Player) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        return label
    }
}
