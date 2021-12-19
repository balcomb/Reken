//
//  PieceView.swift
//  Reken
//
//  Created by Ben Balcomb on 12/18/21.
//

import UIKit

class PieceView: UIView {

    var piece: Piece!
    lazy var anchor = UIView()
    lazy var limbs = [LimbView]()

    convenience init(piece: Piece, size: CGFloat) {
        self.init()
        self.piece = piece
        snp.makeConstraints { make in
            make.width.height.equalTo(size)
        }
        let anchorSize = size * 0.7
        addSubview(anchor)
        anchor.backgroundColor = .blue
        anchor.layer.cornerRadius = anchorSize / 2
        anchor.snp.makeConstraints { make in
            make.width.height.equalTo(anchorSize)
            make.center.equalToSuperview()
        }
        addLimbs(size: size / 2)
    }

    func addLimbs(size: CGFloat) {
        Piece.Limb.allCases.forEach {
            let limbView = LimbView(limb: $0, size: size)
            limbs.append(limbView)
            insertSubview(limbView, belowSubview: anchor)
            limbView.makeConstraints(positionView: anchor)
            limbView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    class LimbView: UIView {
        var limb: Piece.Limb!
        var size: CGFloat = 0

        lazy var tab: UIView = {
            let tab = UIView()
            tab.backgroundColor = .gray
            tab.layer.cornerRadius = size / 2
            return tab
        }()

        lazy var connector: UIView = {
            let connector = UIView()
            connector.backgroundColor = .init(white: 0.5, alpha: 0.5)
            return connector
        }()

        convenience init(limb: Piece.Limb, size: CGFloat) {
            self.init()
            self.limb = limb
            self.size = size
            addSubview(connector)
            addSubview(tab)

            let inset: CGFloat = 2
            connector.snp.makeConstraints { make in
                switch limb {
                case .left:
                    make.left.equalTo(tab.snp.centerX)
                    make.right.equalTo(snp.centerX)
                    make.top.bottom.equalTo(tab).inset(inset)
                case .right:
                    make.right.equalTo(tab.snp.centerX)
                    make.left.equalTo(snp.centerX)
                    make.top.bottom.equalTo(tab).inset(inset)
                case .up:
                    make.top.equalTo(tab.snp.centerY)
                    make.bottom.equalTo(snp.centerY)
                    make.left.right.equalTo(tab).inset(inset)
                case .down:
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
