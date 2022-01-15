//
//  Automaton.swift
//  Reken
//
//  Created by Ben Balcomb on 1/15/22.
//

import Foundation

struct Automaton {

    private let player: GameLogic.Player
    private var board: Board

    init(player: GameLogic.Player, board: Board) {
        self.player = player
        self.board = board
    }

    func findMove() -> Point? {
        var candidates = [(location: Point, scoreDiff: Int)]()
        board.emptyLocations.forEach {
            var boardCopy = board
            guard let _ = boardCopy.addAnchor(at: $0, player: player) else { return }
            let scoreDiff: Int
            switch player {
            case .blue: scoreDiff = boardCopy.score.blue - boardCopy.score.orange
            case .orange: scoreDiff = boardCopy.score.orange - boardCopy.score.blue
            }
            candidates.append(($0, scoreDiff))
        }
        guard !candidates.isEmpty else { return nil }
        let nonCapturableCandidates = candidates.filter {
            !couldCapture(at: $0.location)
        }
        if !nonCapturableCandidates.isEmpty { candidates = nonCapturableCandidates }
        candidates = candidates.sorted { $0.scoreDiff > $1.scoreDiff }
        guard let maxScoreDiff = candidates.first?.scoreDiff else { return nil }
        candidates = candidates.filter { $0.scoreDiff == maxScoreDiff }
        return candidates.randomElement()?.location
    }

    private func couldCapture(at location: Point) -> Bool {
        let anchorCandidate = Anchor(location: location, player: player)
        let diagonals: [[Anchor.Diagonal]] = [[.northwest, .southeast], [.northeast, .southwest]]
        for pair in diagonals {
            let capturePoints = pair.map { diagonal in anchorCandidate.getLocation(for: diagonal) }
            let captureNodes = capturePoints.compactMap { location in board.getNode(at: location) }
            guard captureNodes.count == 2 else { continue }
            let capturePieces: [Piece] = captureNodes.compactMap { $0.piece }

            if capturePieces.count == 1,
               let anchor = capturePieces.first as? Anchor,
               anchor.player == player.opponent,
               !anchorWouldCapture(anchorCandidate, anchor: anchor) {
                return true
            }
        }
        return false
    }

    private func anchorWouldCapture(_ anchorCandidate: Anchor, anchor: Anchor) -> Bool {
        guard let diagonal = Anchor.Diagonal.allCases.first(
            where: { anchorCandidate.getLocation(for: $0) == anchor.location }
        ) else {
            return false
        }

        let location = anchor.getLocation(for: diagonal)
        let captureCandidate = (board.getNode(at: location)?.piece as? Anchor)
        return captureCandidate?.player == anchorCandidate.player
    }
}
