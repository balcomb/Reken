//
//  PieceView.swift
//  Reken
//
//  Created by Ben Balcomb on 12/18/21.
//

import UIKit

class PieceView: UIView {

    lazy var stems = [StemView]()
    private lazy var anchorView = UIView()

    convenience init(anchor: Anchor, size: CGFloat) {
        self.init()
        snp.makeConstraints { make in
            make.width.height.equalTo(size)
        }
        let anchorSize = size * 0.7
        addSubview(anchorView)
        anchorView.backgroundColor = .blue
        anchorView.layer.cornerRadius = anchorSize / 2
        anchorView.snp.makeConstraints { make in
            make.width.height.equalTo(anchorSize)
            make.center.equalToSuperview()
        }
        addStems(size: size / 2)
    }

    private func addStems(size: CGFloat) {
        Stem.Direction.allCases.forEach {
            let stemView = StemView(direction: $0, size: size)
            stems.append(stemView)
            insertSubview(stemView, belowSubview: anchorView)
            stemView.makeConstraints(positionView: anchorView)
            stemView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    class StemView: UIView {
        var direction: Stem.Direction!
        private var size: CGFloat = 0

        private lazy var tab: UIView = {
            let tab = UIView()
            tab.backgroundColor = .gray
            tab.layer.cornerRadius = size / 2
            return tab
        }()

        private lazy var connector: UIView = {
            let connector = UIView()
            connector.backgroundColor = .init(white: 0.5, alpha: 0.5)
            return connector
        }()

        convenience init(direction: Stem.Direction, size: CGFloat) {
            self.init()
            self.direction = direction
            self.size = size
            addSubview(connector)
            addSubview(tab)

            let inset: CGFloat = 2
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
