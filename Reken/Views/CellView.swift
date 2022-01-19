//
//  CellView.swift
//  Reken
//
//  Created by Ben Balcomb on 12/14/21.
//

import UIKit
import Combine

class CellView: UIView {

    var tapPublisher: EventPublisher<Void> { tapSubject.eraseToAnyPublisher() }
    private lazy var tapSubject = EventSubject<Void>()
    private lazy var background = UIView(color: .cellBackground)
    private var selectionView: UIView?

    override func layoutSubviews() {
        guard background.superview == nil else { return }
        setUpAuxiliaryView(background)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    func setSelected(_ isSelected: Bool) {
        guard isSelected else {
            selectionView?.removeFromSuperview()
            selectionView = nil
            return
        }
        let selectionView = UIView(color: .selectionBackground)
        self.selectionView = selectionView
        setUpAuxiliaryView(selectionView)
        renderSelection()
    }

    private func renderSelection() {
        UIView.animate(withDuration: 0.9) {
            guard let selectionView = self.selectionView else { return }
            let showAlpha: CGFloat = 1
            selectionView.alpha = selectionView.alpha == showAlpha ? 0.2 : showAlpha
        } completion: { _ in
            guard self.selectionView != nil else { return }
            self.renderSelection()
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
