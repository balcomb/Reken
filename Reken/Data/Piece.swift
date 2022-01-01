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

protocol Piece {
    var location: Point { get }
}

struct Anchor: Piece {
    let location: Point
    let player: GameLogic.Player
    var stems: [Stem] = []
    var score: Int { Stem.Direction.allCases.count - stems.count }
}

struct Stem: Piece {
    let anchor: Anchor
    let direction: Direction

    var location: Point {
        var location = anchor.location
        switch direction {
        case .north: location.y -= 1
        case .south: location.y += 1
        case .east: location.x += 1
        case .west: location.x -= 1
        }
        return location
    }

    enum Direction: CaseIterable {
        case north, south, east, west
    }
}
