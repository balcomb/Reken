//
//  CellView.swift
//  Reken
//
//  Created by Ben Balcomb on 12/14/21.
//

import UIKit
import Combine

class CellView: UIView {

    var isSelected = false {
        didSet {
            selectionView?.removeFromSuperview()
            selectionView = nil
            guard isSelected else { return }
            let selectionView = UIView(color: .selectionBackground)
            self.selectionView = selectionView
            setUpAuxiliaryView(selectionView)
            renderSelection(view: selectionView)
        }
    }

    var tapPublisher: EventPublisher<Void> { tapSubject.eraseToAnyPublisher() }
    private lazy var tapSubject = EventSubject<Void>()
    private lazy var background = UIView(color: .cellBackground)
    private var selectionView: UIView?

    override func layoutSubviews() {
        guard background.superview == nil else { return }
        setUpAuxiliaryView(background)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    private func renderSelection(view: UIView) {
        UIView.animate(withDuration: 0.9) {
            let showAlpha: CGFloat = 1
            view.alpha = view.alpha == showAlpha ? 0.2 : showAlpha
        } completion: { _ in
            guard view === self.selectionView else { return }
            self.renderSelection(view: view)
        }
    }

    @objc private func handleTap() {
        tapSubject.send()
    }

    private func setUpAuxiliaryView(_ view: UIView) {
        addSubview(view)
        view.layer.cornerRadius = 3
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(1.5)
        }
    }
}
