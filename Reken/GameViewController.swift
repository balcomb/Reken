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
    private lazy var scoreView = ScoreView(dataSource: gameLogic)
    private lazy var boardView = BoardView(dataSource: gameLogic)
    private lazy var controlView = ControlView(dataSource: gameLogic)

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gameBackground
        view.addSubview(boardView)
        view.addSubview(scoreView)
        view.addSubview(controlView)
        makeConstraints()
        gameLogic.startNewGame()
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
        controlView.snp.makeConstraints { make in
            make.top.equalTo(boardView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
