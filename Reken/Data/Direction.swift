//
//  Direction.swift
//  Reken
//
//  Created by Ben Balcomb on 2/25/22.
//

import Foundation

protocol Direction: CaseIterable, Equatable {
    var positionDelta: Board.Position { get }
}

extension Direction {

    var opposite: Self {
        var opposite: Self!
        for direction in Self.allCases {
            let sumOfDeltas = positionDelta + direction.positionDelta
            guard sumOfDeltas == .zero else { continue }
            opposite = direction
            break
        }
        return opposite
    }

    static var opposites: [(Self, Self)] {
        var opposites = [(Self, Self)]()
        Self.allCases.forEach { direction in
            guard !opposites.contains(
                where: { $0.0 == direction || $0.1 == direction }
            ) else {
                return
            }
            opposites.append((direction, direction.opposite))
        }
        return opposites
    }
}

enum Cardinal: Direction {
    case north, south, east, west

    var positionDelta: Board.Position {
        var delta = Board.Position.zero
        let unit = 1
        switch self {
        case .north: delta.y -= unit
        case .south: delta.y += unit
        case .east: delta.x += unit
        case .west: delta.x -= unit
        }
        return delta
    }
}

enum Ordinal: Direction {
    case northwest, northeast, southeast, southwest

    var positionDelta: Board.Position {
        switch self {
        case .northwest: return Cardinal.north.positionDelta + Cardinal.west.positionDelta
        case .northeast: return Cardinal.north.positionDelta + Cardinal.east.positionDelta
        case .southeast: return Cardinal.south.positionDelta + Cardinal.east.positionDelta
        case .southwest: return Cardinal.south.positionDelta + Cardinal.west.positionDelta
        }
    }
}
