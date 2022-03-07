//
//  SettingsView.swift
//  Reken
//
//  Created by Ben Balcomb on 3/1/22.
//

import UIKit
import Combine

class SettingsView: UIView, EventSubscriber {

    var cancellables = Set<AnyCancellable>()
    private var dataSource: GameDataSource!

    private lazy var doneButton = Self.makeButton(title: "Done") { [weak self] _ in
        self?.renderVisibility(isVisible: false)
    }

    private lazy var newGameButton = Self.makeButton(
        title: "New Game",
        titleColor: .yellow
    ) { [weak self] _ in
        self?.dataSource.startNewGame()
    }

    private lazy var gameTypeOptionView = OptionView<Settings.GameType>(
        title: "Game Type",
        optionTextProvider: {
            let mainText = " Player"
            switch $0 {
            case .onePlayer: return "1" + mainText
            case .twoPlayer: return "2" + mainText + "s"
            }
        }
    )

    private lazy var skillLevelOptionView = OptionView<Settings.SkillLevel>(
        title: "Skill Level",
        optionTextProvider: { $0.rawValue.capitalized }
    )

    convenience init(dataSource: GameDataSource) {
        self.init()
        self.dataSource = dataSource
        alpha = 0
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(gameTypeOptionView)
        addSubview(skillLevelOptionView)
        addSubview(newGameButton)
        addSubview(doneButton)
        subviews.forEach {
            $0.backgroundColor = .gray
            $0.layer.cornerRadius = 4
        }
        makeConstraints()
        subscribeToEvents()
    }

    private static func makeButton(
        title: String,
        titleColor: UIColor = .white,
        image: UIImage? = nil,
        handler: @escaping UIActionHandler
    ) -> UIButton {
        let button = UIButton(type: .system, primaryAction: UIAction(handler: handler))
        var imageBuffer = ""
        if let image = image {
            button.setImage(image, for: .normal)
            button.tintColor = titleColor
            imageBuffer = " "
        }
        button.setTitle(imageBuffer + title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
        return button
    }

    private func subscribeToEvents() {
        subscribe(to: dataSource.settingsIsVisiblePublisher) { [weak self] in
            self?.renderVisibility(isVisible: $0)
        }
        subscribe(to: dataSource.settingsPublisher) { [weak self] in
            self?.renderSettings($0)
        }
        subscribe(to: gameTypeOptionView.selectionPublisher) { [weak self] in
            self?.dataSource.updateSettings(option: $0)
        }
        subscribe(to: skillLevelOptionView.selectionPublisher) { [weak self] in
            self?.dataSource.updateSettings(option: $0)
        }
    }

    private func renderSettings(_ settings: Settings) {
        gameTypeOptionView.selectedOption = settings.gameType
        skillLevelOptionView.selectedOption = settings.skillLevel
        let is1Player = settings.gameType == .onePlayer
        skillLevelOptionView.alpha = is1Player ? 1 : 0.4
        skillLevelOptionView.isUserInteractionEnabled = is1Player
    }

    private func renderVisibility(isVisible: Bool) {
        makeDoneButtonConstraints(isVisible: isVisible)
        superview?.bringSubviewToFront(self)
        UIView.animate(withDuration: 0.3) {
            self.alpha = isVisible ? 1 : 0
            self.layoutIfNeeded()
        }
    }

    private func makeConstraints() {
        var viewBelow: UIView = doneButton
        [newGameButton, skillLevelOptionView, gameTypeOptionView].forEach {
            $0.snp.makeConstraints { make in
                make.left.right.equalTo(doneButton)
                make.bottom.equalTo(viewBelow.snp.top).offset(-5)
            }
            viewBelow = $0
        }
        makeDoneButtonConstraints(isVisible: false)
    }

    private func makeDoneButtonConstraints(isVisible: Bool) {
        doneButton.snp.remakeConstraints { make in
            let inset: CGFloat = 16
            make.bottom.equalTo(safeAreaLayoutGuide).inset(inset)
            make.width.equalTo(newGameButton.intrinsicContentSize.width * 2)
            if isVisible {
                make.right.equalToSuperview().inset(inset)
            } else {
                make.left.equalTo(snp.right)
            }
        }
    }
}

extension SettingsView {

    class OptionView<Option: SettingsOption>: UIView {

        var selectedOption: Option? {
            didSet { updateButtons() }
        }

        private lazy var selectionSubject = EventSubject<Option>()
        var selectionPublisher: EventPublisher<Option> { selectionSubject.eraseToAnyPublisher() }

        private lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
            label.textColor = .white
            return label
        }()

        private lazy var optionButtons = [Option: UIButton]()

        convenience init(
            title: String,
            optionTextProvider: (Option) -> String
        ) {
            self.init()
            titleLabel.text = title
            addSubview(titleLabel)
            makeButtons(optionTextProvider: optionTextProvider)
            makeConstraints()
        }

        private func makeButtons(optionTextProvider: (Option) -> String) {
            Option.allCases.forEach { option in
                let button = SettingsView.makeButton(
                    title: optionTextProvider(option),
                    image: getImage(for: option),
                    handler: { [weak self] _ in self?.selectionSubject.send(option) }
                )
                optionButtons[option] = button
                addSubview(button)
            }
        }

        private func makeConstraints() {
            let padding = CGFloat(11)
            titleLabel.snp.makeConstraints { make in
                make.top.left.equalToSuperview().inset(padding)
            }
            var prevView: UIView = titleLabel
            Option.allCases.forEach { option in
                guard let button = optionButtons[option] else { return }
                button.snp.makeConstraints { make in
                    make.top.equalTo(prevView.snp.bottom).offset(padding)
                    make.leading.equalToSuperview().inset(padding)
                }
                prevView = button
            }
            snp.makeConstraints { make in
                make.bottom.equalTo(prevView).offset(padding)
            }
        }

        private func getImage(for option: Option) -> UIImage? {
            UIImage(
                systemName: option == selectedOption ? "checkmark.circle.fill" : "circle",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: UIFont.systemFontSize,
                    weight: .bold
                )
            )
        }

        private func updateButtons() {
            Option.allCases.forEach {
                optionButtons[$0]?.setImage(getImage(for: $0), for: .normal)
            }
        }
    }
}
