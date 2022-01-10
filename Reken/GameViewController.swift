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
    private lazy var grid = GridView(size: Board.gridSize)
    private lazy var cancellables = Set<AnyCancellable>()
    lazy var scoreLabel: UILabel = {
        let label = UILabel()
        view.addSubview(label)
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(grid.snp.top)
        }
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        view.addSubview(grid)
        grid.tapPublisher.sink { [weak self] in self?.handleTap(location: $0) }
            .store(in: &cancellables)

        grid.snp.makeConstraints { make in
            make.height.equalTo(grid.snp.width)
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(9)
        }
    }

    private func handleTap(location: Point) {
        print("\(location.x), \(location.y)")
        guard let result = gameLogic.addAnchor(at: location) else { return }
        result.updatedAnchors.forEach {
            print("updated: \($0.location.x), \($0.location.y)")
        }
        result.capturedAnchors.forEach {
            print("captured: \($0.location.x), \($0.location.y)")
        }
        grid.updatePieces(moveResult: result)
        scoreLabel.text = "\(gameLogic.score.blue) | \(gameLogic.score.orange)"
        guard result.newPiece.player == .blue else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            guard let location = self.gameLogic.autoMove() else { return }
            self.handleTap(location: location)
        }
    }
}
