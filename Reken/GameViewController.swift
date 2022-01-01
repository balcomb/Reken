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

    lazy var board = Board()
    private lazy var grid = GridView(size: Board.gridSize)
    private lazy var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
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
        guard let anchor = board.addAnchor(at: location) else { return }
        grid.addPiece(anchor: anchor)
    }
}
