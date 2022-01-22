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

    func findMove() -> Board.Position? {
        var candidates = [(position: Board.Position, scoreDiff: Int)]()
        board.openPositions.forEach {
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
            !couldCapture(at: $0.position)
        }
        if !nonCapturableCandidates.isEmpty { candidates = nonCapturableCandidates }
        candidates = candidates.sorted { $0.scoreDiff > $1.scoreDiff }
        guard let maxScoreDiff = candidates.first?.scoreDiff else { return nil }
        candidates = candidates.filter { $0.scoreDiff == maxScoreDiff }
        return candidates.randomElement()?.position
    }

    private func couldCapture(at position: Board.Position) -> Bool {
        let anchorCandidate = Anchor(position: position, player: player)
        let diagonals: [[Anchor.Diagonal]] = [[.northwest, .southeast], [.northeast, .southwest]]
        for pair in diagonals {
            let capturePositions = pair.compactMap { diagonal in
                anchorCandidate.getPosition(for: diagonal).selfIfValid
            }
            guard capturePositions.count == 2 else { continue }
            let capturePieces = capturePositions.compactMap { board.getPiece(at: $0) }

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
            where: { anchorCandidate.getPosition(for: $0) == anchor.position }
        ) else {
            return false
        }

        let position = anchor.getPosition(for: diagonal)
        let captureCandidate = board.getAnchor(at: position)
        return captureCandidate?.player == anchorCandidate.player
    }
}
