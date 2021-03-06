//
//  PieceView.swift
//  Reken
//
//  Created by Ben Balcomb on 12/18/21.
//

import UIKit

class PieceView: UIView {

    lazy var stems = [Cardinal: StemView]()
    private var size: CGFloat = 0

    private lazy var anchorView: UIView = {
        let anchorView = UIView()
        anchorView.layer.borderWidth = size * 0.25
        anchorView.layer.cornerRadius = anchorContainer.layer.cornerRadius
        return anchorView
    }()

    private lazy var anchorContainer: UIView = {
        let anchorContainer = UIView()
        anchorContainer.backgroundColor = .white
        anchorContainer.layer.cornerRadius = size / 2
        anchorContainer.layer.shadowColor = UIColor.gameBackground.cgColor
        anchorContainer.layer.shadowRadius = 3
        anchorContainer.layer.shadowOpacity = 0.5
        anchorContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        return anchorContainer
    }()

    convenience init(anchor: Anchor, cellSize: CGFloat) {
        self.init()
        self.size = cellSize * 0.7
        snp.makeConstraints { make in
            make.width.height.equalTo(size)
        }
        addSubview(anchorContainer)
        anchorContainer.addSubview(anchorView)
        updateView(with: anchor)
        anchorContainer.snp.makeConstraints { make in
            make.width.height.equalTo(size)
            make.center.equalToSuperview()
        }
        anchorView.snp.makeConstraints { $0.edges.equalToSuperview() }
        addStems(size: size * 0.6)
    }

    func updateView(with anchor: Anchor) {
        let color = UIColor(for: anchor.player)
        let alpha: CGFloat = {
            if anchor.score == 0 { return 1 }
            let maxScore = Cardinal.allCases.count
            if anchor.score == maxScore { return 0 }
            return (CGFloat(maxScore - anchor.score) * 0.2) + 0.05
        }()
        anchorView.backgroundColor = color.withAlphaComponent(alpha)
        anchorView.layer.borderColor = color.cgColor
    }

    private func addStems(size: CGFloat) {
        Cardinal.allCases.forEach {
            let stemView = StemView(direction: $0, size: size)
            stems[$0] = stemView
            insertSubview(stemView, belowSubview: anchorContainer)
            stemView.makeConstraints(positionView: anchorContainer)
            stemView.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
    }

    func resetStems() {
        stems.values.forEach { $0.makeConstraints(positionView: self) }
    }
}

extension PieceView {

    class StemView: UIView {
        private var size: CGFloat = 0

        private lazy var tab: UIView = {
            let tab = UIView()
            tab.backgroundColor = .gray
            tab.layer.cornerRadius = size / 2
            tab.layer.borderColor = UIColor.gameBackground.cgColor
            tab.layer.borderWidth = 0.5
            return tab
        }()

        private lazy var connector: UIView = {
            let connector = UIView()
            connector.backgroundColor = .connectorBackground
            return connector
        }()

        convenience init(direction: Cardinal, size: CGFloat) {
            self.init()
            self.size = size
            addSubview(connector)
            addSubview(tab)
            makeConnectorConstraints(with: direction)
        }

        private func makeConnectorConstraints(with direction: Cardinal) {
            let inset: CGFloat = size * 0.15
            connector.snp.makeConstraints { make in
                switch direction {
                case .west:
                    make.left.equalTo(tab.snp.centerX)
                    make.right.equalTo(snp.centerX)
                    make.top.bottom.equalTo(tab).inset(inset)
                case .east:
                    make.right.equalTo(tab.snp.centerX)
                    make.left.equalTo(snp.centerX)
                    make.top.bottom.equalTo(tab).inset(inset)
                case .north:
                    make.top.equalTo(tab.snp.centerY)
                    make.bottom.equalTo(snp.centerY)
                    make.left.right.equalTo(tab).inset(inset)
                case .south:
                    make.bottom.equalTo(tab.snp.centerY)
                    make.top.equalTo(snp.centerY)
                    make.left.right.equalTo(tab).inset(inset)
                }
            }
        }

        func makeConstraints(positionView: UIView) {
            tab.snp.remakeConstraints { make in
                make.center.equalTo(positionView)
                make.width.height.equalTo(size)
            }
        }
    }
}
