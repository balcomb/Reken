//
//  CellView.swift
//  Reken
//
//  Created by Ben Balcomb on 12/14/21.
//

import UIKit
import Combine

class CellView: UIView {

    var tapPublisher: AnyPublisher<Void, Never> { tapSubject.eraseToAnyPublisher() }
    private lazy var tapSubject = PassthroughSubject<Void, Never>()
    private lazy var background = UIView(color: .cellBackground)

    override func layoutSubviews() {
        guard background.superview == nil else { return }
        addSubview(background)
        background.layer.cornerRadius = 3
        background.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(1.5)
        }
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    @objc private func handleTap() {
        tapSubject.send()
    }
}
