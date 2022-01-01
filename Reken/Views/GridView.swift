//
//  GridView.swift
//  Reken
//
//  Created by Ben Balcomb on 12/14/21.
//

import UIKit
import Combine

class GridView: UIView {

    var tapPublisher: AnyPublisher<Point, Never> { tapSubject.eraseToAnyPublisher() }
    private lazy var tapSubject = PassthroughSubject<Point, Never>()
    private var size: Int!
    private lazy var cells = [[UIView]]()
    private lazy var cancellables = Set<AnyCancellable>()

    convenience init(size: Int) {
        self.init()
        self.size = size
        makeCells()
    }

    func addPiece(anchor: Anchor) {
        guard let cell = cells[anchor.location] else { return }
        let pieceView = PieceView(anchor: anchor, size: cell.frame.width)
        addSubview(pieceView)
        pieceView.snp.makeConstraints { make in
            make.center.equalTo(cell)
        }
        layoutIfNeeded()
        anchor.stems.forEach { stem in
            guard let stemCell = cells[stem.location],
                  let stemView = pieceView.stems.first(where: { $0.direction == stem.direction })
            else {
                return
            }
            stemView.makeConstraints(positionView: stemCell)
        }
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

    private func makeCells() {

        var prevCell: CellView?

        for x in 0 ..< size {
            cells.append([])

            for y in 0 ..< size {
                let cell = CellView()
                addSubview(cell)
                cells[x].append(cell)
                setUpPublisher(cell: cell, location: (x, y))
                makeConstraints(for: cell, y: y, prevCell: prevCell)
                prevCell = cell
            }
        }
    }

    private func setUpPublisher(cell: CellView, location: Point) {
        cell.tapPublisher.sink { [weak self] in
            self?.tapSubject.send(location)
        }.store(in: &cancellables)
    }

    private func makeConstraints(for cell: CellView, y: Int, prevCell: CellView?) {

        cell.snp.makeConstraints { make in
            if let prevCell = prevCell {
                if y == 0 {
                    make.left.equalTo(prevCell.snp.right)
                    make.top.equalToSuperview()
                } else {
                    make.left.equalTo(prevCell)
                    make.top.equalTo(prevCell.snp.bottom)
                }
            } else {
                make.left.top.equalToSuperview()
            }

            make.width.equalToSuperview().dividedBy(size)
            make.height.equalTo(cell.snp.width)
        }
    }
}
