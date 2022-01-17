//
//  UIExtensions.swift
//  Reken
//
//  Created by Ben Balcomb on 1/17/22.
//

import UIKit

extension UIView {

    convenience init(color: UIColor) {
        self.init()
        backgroundColor = color
    }
}

extension UIColor {

    convenience init(for player: GameLogic.Player) {
        switch player {
        case .blue: self.init(red: 0, green: 0.5, blue: 0.85, alpha: 1)
        case .orange: self.init(red: 0.9, green: 0.5, blue: 0, alpha: 1)
        }
    }

    static var gameBackground: UIColor { .init(white: 0.2, alpha: 1) }
    static var cellBackground: UIColor { .init(white: 0.28, alpha: 1) }
    static var connectorBackground: UIColor { .init(white: 0.4, alpha: 0.7) }
}
