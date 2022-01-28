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

    private let player: GameLogic.Player
    private var board: Board

    init(player: GameLogic.Player, board: Board) {
        self.player = player
        self.board = board
    }

    func findMove() -> Board.Position? {
        if let winningMove = getWinningMove() { return winningMove }
        var candidates = getAllMoveCandidates()
        guard !candidates.isEmpty else { return nil }
        filterCapturableMoves(from: &candidates)
        filterRecapturableMoves(from: &candidates)
        prioritizeCaptureBlockingMoves(for: &candidates)
        let maxScoreDiff = candidates.map { $0.scoreDiff }.max()
        candidates.removeAll { $0.scoreDiff != maxScoreDiff }
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
            for diagonal in Anchor.Diagonal.allCases {
                let diagonalPosition = pair.anchor.getPosition(for: diagonal)
                guard let currentDiagonalAnchor = board.getAnchor(at: diagonalPosition),
                      let updatedDiagonalAnchor = pair.boardCopy.getAnchor(at: diagonalPosition),
                      currentDiagonalAnchor.player != updatedDiagonalAnchor.player,
                      anchorCouldBeCaptured(at: diagonalPosition, on: pair.boardCopy)
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
            !anchorCouldBeCaptured(at: $0.position, on: board)
        }
        guard firstNoncapturableCandidate != nil else { return }
        candidates.removeAll { anchorCouldBeCaptured(at: $0.position, on: board) }
    }

    private func anchorCouldBeCaptured(at position: Board.Position, on board: Board) -> Bool {
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

    private func prioritizeCaptureBlockingMoves(for candidates: inout [MoveCandidate]) {
        var anchorDiagonalPairs = [(anchor: Anchor, diagonal: Anchor.Diagonal)]()
        var captureBlockingMoves = candidates.filter { candidate in
            var wouldBlock = false
            let anchorCandidate = Anchor(position: candidate.position, player: player)
            for diagonal in Anchor.Diagonal.allCases {
                if let anchor1 = board.getAnchor(at: anchorCandidate.getPosition(for: diagonal)),
                   anchor1.player == player,
                   let anchor2 = board.getAnchor(at: anchor1.getPosition(for: diagonal)),
                   anchor2.player == player.opponent {
                    anchorDiagonalPairs.append((anchor2, diagonal))
                    wouldBlock = true
                    break
                }
            }
            return wouldBlock
        }
        anchorDiagonalPairs.forEach { pair in
            let position = pair.anchor.getPosition(for: pair.diagonal)
            guard let candidate = candidates.first(where: { $0.position == position }),
                  !anchorCouldBeCaptured(at: position, on: board)
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
