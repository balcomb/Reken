//
//  Piece.swift
//  Reken
//
//  Created by Ben Balcomb on 12/18/21.
//

import Foundation

typealias Point = (x: Int, y: Int)

extension Array where Element : Collection, Element.Index == Int {

    subscript(point: Point) -> Element.Element? {
        let x = point.x
        let y = point.y
        guard indices.contains(x), self[x].indices.contains(y) else { return nil }
        return self[x][y]
    }
}

struct Piece {
    let location: Point
    var limbs: [Limb] = Limb.allCases

    enum Limb: CaseIterable {
        case left, right, up, down

        func location(piece: Piece) -> Point {
            var location = piece.location
            switch self {
            case .left: location.x -= 1
            case .right: location.x += 1
            case .up: location.y -= 1
            case .down: location.y += 1
            }
            return location
        }
    }
}
