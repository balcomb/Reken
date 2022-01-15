//
//  ScoreboardView.swift
//  Reken
//
//  Created by Ben Balcomb on 1/15/22.
//

import UIKit

class ScoreboardView: UIView {

    private var views: [UIView] { [blueLabel, orangeLabel, separator] }
    private lazy var blueLabel = makeScoreLabel()
    private lazy var orangeLabel = makeScoreLabel()

    private lazy var separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = .darkGray
        return separator
    }()

    convenience init(state: GameLogic.State) {
        self.init()
        setState(state)
        views.forEach { addSubview($0) }
        makeConstraints()
    }

    func setState(_ state: GameLogic.State) {
        blueLabel.text = String(state.score.blue)
        orangeLabel.text = String(state.score.orange)
    }

    private func makeConstraints() {
        snp.makeConstraints { make in
            make.bottom.equalTo(separator)
        }
        separator.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(blueLabel)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        let labelHorizontalOffset: CGFloat = 10
        blueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(separator)
            make.trailing.equalTo(separator.snp.leading).offset(-labelHorizontalOffset)
        }
        orangeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(separator)
            make.leading.equalTo(separator.snp.trailing).offset(labelHorizontalOffset)
        }
    }

    private func makeScoreLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        return label
    }
}
