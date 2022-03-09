//
//  ConfirmView.swift
//  Reken
//
//  Created by Ben Balcomb on 1/17/22.
//

import UIKit
import Combine

class ConfirmView: UIView {

    lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
    private lazy var actionSubject = EventSubject<GameLogic.ConfirmAction>()
    private lazy var confirmButton = makeButton(for: .confirm)
    private lazy var rejectButton = makeButton(for: .reject)
    private var padding: CGFloat { 5 }

    override func didMoveToSuperview() {
        guard confirmButton.superview == nil else { return }
        alpha = 0
        backgroundColor = .lightGray.withAlphaComponent(0.9)
        layer.cornerRadius = 4
        addSubview(confirmButton)
        addSubview(rejectButton)
        makeConstraints()
    }

    func show(for cell: CellView, isAlignedLeft: Bool) {
        snp.remakeConstraints { make in
            make.top.equalTo(cell.snp.bottom)
            make.trailing.equalTo(rejectButton).offset(padding)
            make.bottom.equalTo(confirmButton)
            if isAlignedLeft {
                make.left.equalTo(cell)
            } else {
                make.right.equalTo(cell)
            }
        }
        animate(alpha: 1)
    }

    func hide() {
        animate(alpha: 0)
    }

    private func animate(alpha: CGFloat) {
        UIView.animate(withDuration: 0.2) { self.alpha = alpha }
    }

    private func makeConstraints() {
        let size = 33
        confirmButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(padding)
            make.width.height.equalTo(size)
        }
        rejectButton.snp.makeConstraints { make in
            make.top.equalTo(confirmButton)
            make.leading.equalTo(confirmButton.snp.trailing)
            make.width.height.equalTo(size)
        }
    }

    private func makeButton(for action: GameLogic.ConfirmAction) -> UIButton {
        let button = UIButton(
            type: .system,
            primaryAction: .init(handler: { [weak self] _ in self?.actionSubject.send(action) })
        )
        let image = UIImage(
            systemName: action == .confirm ? "checkmark" : "multiply",
            withConfiguration: UIImage.SymbolConfiguration(weight: .black)
        )
        button.setImage(image, for: .normal)
        button.tintColor = action == .confirm ? .white : .gameBackground
        return button
    }
}
