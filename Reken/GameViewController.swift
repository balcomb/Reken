//
//  GameViewController.swift
//  Reken
//
//  Created by Ben Balcomb on 11/27/21.
//

import UIKit
import SnapKit
import Combine

class GameViewController: UIViewController, EventSubscriber {

    lazy var cancellables = Set<AnyCancellable>()
    private lazy var dataSource: GameDataSource = GameLogic()
    private lazy var scoreView = ScoreView(dataSource: dataSource)
    private lazy var boardView = BoardView(dataSource: dataSource)
    private lazy var controlView = ControlView(dataSource: dataSource)
    private lazy var settingsView = SettingsView(dataSource: dataSource)

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gameBackground
        view.addSubview(boardView)
        view.addSubview(scoreView)
        view.addSubview(controlView)
        view.addSubview(settingsView)
        makeConstraints()
        dataSource.startNewGame()
        subscribe(to: dataSource.settingsErrorPublisher) { [weak self] in
            self?.showSettingErrorDialog()
        }
    }

    private func showSettingErrorDialog() {
        let alertController = UIAlertController(
            title: "Sorry, your settings couldn't be saved",
            message: nil,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
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
        settingsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
