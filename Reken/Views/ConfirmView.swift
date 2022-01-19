//
//  ConfirmView.swift
//  Reken
//
//  Created by Ben Balcomb on 1/17/22.
//

import UIKit
import Combine

class ConfirmView: UIView {

    var actionPublisher: EventPublisher<Action> { actionSubject.eraseToAnyPublisher() }
    private lazy var actionSubject = EventSubject<Action>()
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
        animate(alpha: 1)
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

    private func makeButton(for event: Action) -> UIButton {
        let button = UIButton(
            primaryAction: .init(handler: { [weak self] _ in self?.handleButton(for: event) })
        )
        let image = UIImage(
            systemName: event == .confirm ? "checkmark" : "multiply",
            withConfiguration: UIImage.SymbolConfiguration(weight: .black)
        )
        button.setImage(image, for: .normal)
        button.tintColor = event == .confirm ? .white : .gameBackground
        return button
    }

    private func handleButton(for event: Action) {
        actionSubject.send(event)
        animate(alpha: 0)
    }
}

extension ConfirmView {

    enum Action {
        case confirm, reject
    }
}
