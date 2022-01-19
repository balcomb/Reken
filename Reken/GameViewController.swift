//
//  GameViewController.swift
//  Reken
//
//  Created by Ben Balcomb on 11/27/21.
//

import UIKit
import SnapKit

class GameViewController: UIViewController {

    private lazy var gameLogic = GameLogic()
    private lazy var scoreView = ScoreView(state: .initial)
    private lazy var boardView = BoardView(size: Board.gridSize)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gameBackground
        view.addSubview(boardView)
        view.addSubview(scoreView)
        makeConstraints()
        configureUpdaters()
    }

    private func configureUpdaters() {
        gameLogic.addUpdater(boardView)
        boardView.addUpdater(gameLogic)
        scoreView.addUpdater(gameLogic)
    }

    private func makeConstraints() {
        scoreView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(boardView.snp.top).offset(-20)
        }
        boardView.snp.makeConstraints { make in
            make.height.equalTo(boardView.snp.width)
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(9)
        }
    }
}
