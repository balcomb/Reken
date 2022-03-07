//
//  Automaton.swift
//  Reken
//
//  Created by Ben Balcomb on 1/15/22.
//

import Foundation

typealias MoveCandidate = (position: Board.Position, scoreDiff: Int)
typealias AnchorBoardPair = (anchor: Anchor, boardCopy: Board)

struct Automaton {

    private let player: Game.Player
    private var board: Board
    private let skillLevel: Settings.SkillLevel
    private var scoreDiffAdjustment: Int { skillLevel == .basic ? 1 : 0 }

    init(player: Game.Player, board: Board, skillLevel: Settings.SkillLevel) {
        self.player = player
        self.board = board
        self.skillLevel = skillLevel
    }

    func findMove() -> Board.Position? {
        if let winningMove = getWinningMove() { return winningMove }
        var candidates = getAllMoveCandidates()
        guard !candidates.isEmpty else { return nil }
        filterCapturableMoves(from: &candidates)
        filterRecapturableMoves(from: &candidates)
        prioritizeCaptureBlockingMoves(for: &candidates)
        let maxScoreDiff = candidates.map { $0.scoreDiff }.max() ?? 0
        candidates = candidates.filter { $0.scoreDiff >= maxScoreDiff - scoreDiffAdjustment }
        return candidates.randomElement()?.position
    }

    private func getWinningMove() -> Board.Position? {
        let openPositions = board.openPositions
        guard openPositions.count < 6 else { return nil }
        for position in openPositions {
            var boardCopy = board
            guard let _ = boardCopy.addAnchor(at: position, player: player),
                  boardCopy.openPositions.count == 0,
                  boardCopy.scoreDiff(for: player) > 0
            else {
                continue
            }
            return position
        }
        return nil
    }

    private func getAllMoveCandidates() -> [MoveCandidate] {
        board.openPositions.map { position in
            var boardCopy = board
            _ = boardCopy.addAnchor(at: position, player: player)
            return (position, boardCopy.scoreDiff(for: player))
        }
    }

    private func filterRecapturableMoves(from candidates: inout [MoveCandidate]) {
        let anchorBoardPairs = getAnchorBoardPairs(for: candidates)
        let recapturablePositions = getRecapturablePositions(for: anchorBoardPairs)
        guard recapturablePositions.count < candidates.count else { return }
        candidates.removeAll { candidate in
            recapturablePositions.contains { candidate.position == $0 }
        }
    }

    private func getAnchorBoardPairs(for candidates: [MoveCandidate]) -> [AnchorBoardPair] {
        candidates.compactMap {
            var boardCopy = board
            guard let moveResult = boardCopy.addAnchor(at: $0.position, player: player) else {
                return nil
            }
            return (moveResult.newAnchor, boardCopy)
        }
    }

    private func getRecapturablePositions(
        for anchorBoardPairs: [AnchorBoardPair]
    ) -> [Board.Position] {
        anchorBoardPairs.compactMap { pair in
            var isRecapturable = false
            for ordinal in Ordinal.allCases {
                let ordinalPosition = pair.anchor.getPosition(for: ordinal)
                guard let currentOrdinalAnchor = board.getAnchor(at: ordinalPosition),
                      let updatedOrdinalAnchor = pair.boardCopy.getAnchor(at: ordinalPosition),
                      currentOrdinalAnchor.player != updatedOrdinalAnchor.player,
                      anchorCouldBeCaptured(at: ordinalPosition, on: pair.boardCopy, from: player)
                else {
                    continue
                }
                isRecapturable = true
                break
            }
            return isRecapturable ? pair.anchor.position : nil
        }
    }

    private func filterCapturableMoves(from candidates: inout [MoveCandidate]) {
        let firstNoncapturableCandidate = candidates.first {
            !anchorCouldBeCaptured(at: $0.position, on: board, from: player)
        }
        guard firstNoncapturableCandidate != nil else { return }
        candidates.removeAll { anchorCouldBeCaptured(at: $0.position, on: board, from: player) }
    }

    private func anchorCouldBeCaptured(
        at position: Board.Position,
        on board: Board,
        from player: Game.Player
    ) -> Bool {
        let anchorCandidate = Anchor(position: position, player: player)
        for opposites in Ordinal.opposites {
            let capturePositions = [opposites.0, opposites.1].map { ordinal in
                anchorCandidate.getPosition(for: ordinal)
            }
            guard capturePositions.allSatisfy({ $0.isValid }) else { continue }
            let capturePieces = capturePositions.compactMap { board.getPiece(at: $0) }

            guard capturePieces.count == 1,
               let anchor = capturePieces.first as? Anchor,
               anchor.player == player.opponent,
               !anchorCandidateWouldCapture(anchorCandidate, existingAnchor: anchor, on: board)
            else {
                continue
            }
            return true
        }
        return false
    }

    private func anchorCandidateWouldCapture(
        _ anchorCandidate: Anchor,
        existingAnchor: Anchor,
        on board: Board
    ) -> Bool {
        guard let ordinal = Ordinal.allCases.first(
            where: { anchorCandidate.getPosition(for: $0) == existingAnchor.position }
        ) else {
            return false
        }

        let captureCandidate = board.getAnchor(at: existingAnchor.getPosition(for: ordinal))
        return captureCandidate?.player == anchorCandidate.player
    }

    private func prioritizeCaptureBlockingMoves(for candidates: inout [MoveCandidate]) {
        var anchorOrdinalPairs = [(anchor: Anchor, ordinal: Ordinal)]()
        var captureBlockingMoves = candidates.filter { candidate in
            var wouldBlock = false
            var boardCopy = board
            let moveResult = boardCopy.addAnchor(at: candidate.position, player: player)
            guard let anchorCandidate = moveResult?.newAnchor else { return false }
            let pieces: [Piece] = [anchorCandidate] + anchorCandidate.stems
            pieces.forEach { piece in
                for ordinal in Ordinal.allCases {
                    guard let anchor1 = board.getAnchor(at: piece.getPosition(for: ordinal)),
                          anchor1.player == player,
                          let anchor2 = board.getAnchor(at: anchor1.getPosition(for: ordinal)),
                          anchor2.player == player.opponent
                    else {
                        continue
                    }
                    anchorOrdinalPairs.append((anchor2, ordinal))
                    wouldBlock = true
                    break
                }
            }
            return wouldBlock
        }
        anchorOrdinalPairs.forEach { pair in
            let position = pair.anchor.getPosition(for: pair.ordinal)
            guard let candidate = candidates.first(where: { $0.position == position }),
                  !anchorCouldBeCaptured(at: position, on: board, from: player)
            else {
                return
            }
            captureBlockingMoves.append(candidate)
        }
        guard !captureBlockingMoves.isEmpty else { return }
        candidates.removeAll()
        candidates.append(contentsOf: captureBlockingMoves)
    }
}
