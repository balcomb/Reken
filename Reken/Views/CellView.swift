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

    private lazy var background: UIView = {
        let background = UIView()
        background.backgroundColor = .init(white: 1, alpha: 0.8)
        background.layer.cornerRadius = 3
        return background
    }()

    override func layoutSubviews() {
        guard !subviews.contains(background) else { return }
        addSubview(background)
        background.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(1.5)
        }
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    @objc private func handleTap() {
        tapSubject.send()
    }
}
