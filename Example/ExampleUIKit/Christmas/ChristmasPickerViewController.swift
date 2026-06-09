import UIKit
import ThemeKit

class ChristmasPickerViewController: UIViewController {
    private let theme: Theme
    private var variantCheckmarks: [String: UIImageView] = [:]
    private var backgroundThumbnails: [(imageName: String, view: UIView)] = []
    private var iconThumbnails: [(name: String, view: UIView)] = []
    private var accentColorWell: UIColorWell?
    private var resetButton: UIButton?

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let vStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    init(theme: Theme) {
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeAppearance()
        initializeSubviews()
        observeTheme()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyConstraints()
    }

    private func initializeAppearance() {
        view.backgroundColor = .systemGroupedBackground
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
    }

    private func initializeSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(vStack)

        vStack.addArrangedSubview(makeSectionLabel("Appearance"))
        vStack.addArrangedSubview(makeFollowSystemRow())
        vStack.addArrangedSubview(makeSectionLabel("Presets"))
        for variant in ChristmasVariant.all {
            vStack.addArrangedSubview(makeVariantRow(for: variant))
        }
        vStack.addArrangedSubview(makeSectionLabel("Background"))
        vStack.addArrangedSubview(makeBackgroundPickerCard())
        vStack.addArrangedSubview(makeSectionLabel("Icon"))
        vStack.addArrangedSubview(makeIconPickerCard())
        vStack.addArrangedSubview(makeSectionLabel("Accent"))
        vStack.addArrangedSubview(makeAccentRow())
        vStack.addArrangedSubview(makeResetButton())
    }

    private func observeTheme() {
        withObservationTracking {
            let accent = theme.christmas.accent
            let selectedBg = theme.christmas.backgroundImageName
            let selectedIcon = theme.christmas.iconImageName
            let isCustom = theme.christmas.isCustomDefined

            for (id, checkmark) in variantCheckmarks {
                checkmark.isHidden = theme.activeVariantID != id
                checkmark.tintColor = accent
            }
            for (imageName, view) in backgroundThumbnails {
                view.layer.borderColor = (selectedBg == imageName ? accent : .clear).cgColor
            }
            for (name, view) in iconThumbnails {
                view.layer.borderColor = (selectedIcon == name ? accent : .clear).cgColor
            }
            accentColorWell?.selectedColor = accent
            resetButton?.isHidden = !isCustom
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in self?.observeTheme() }
        }
    }

    private func applyConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            vStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            vStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            vStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            vStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
        ])
    }

    // MARK: - Section builders

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }

    private func makeFollowSystemRow() -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Follow System Appearance"
        label.translatesAutoresizingMaskIntoConstraints = false

        let toggle = UISwitch()
        toggle.isOn = theme.followsSystem
        toggle.addAction(UIAction { [weak self, weak toggle] _ in
            guard let self, let toggle else { return }
            theme.followsSystem = toggle.isOn
        }, for: .valueChanged)
        toggle.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(label)
        container.addSubview(toggle)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 52),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            toggle.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            toggle.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])

        return container
    }

    private func makeVariantRow(for variant: ChristmasVariant) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = .secondarySystemGroupedBackground
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            theme.apply(variant: variant, for: SystemColorScheme(traitCollection.userInterfaceStyle))
            theme.followsSystem = false
        }, for: .touchUpInside)

        let lightThumb = makeThumbnail(imageName: variant.light.backgroundImageName)
        let darkThumb = makeThumbnail(imageName: variant.dark.backgroundImageName)

        let nameLabel = UILabel()
        nameLabel.text = variant.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
        checkmark.tintColor = theme.christmas.accent
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        checkmark.isHidden = theme.activeVariantID != variant.id
        variantCheckmarks[variant.id] = checkmark

        button.addSubview(lightThumb)
        button.addSubview(darkThumb)
        button.addSubview(nameLabel)
        button.addSubview(checkmark)

        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 56),

            lightThumb.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            lightThumb.centerYAnchor.constraint(equalTo: button.centerYAnchor),

            darkThumb.leadingAnchor.constraint(equalTo: lightThumb.trailingAnchor, constant: -8),
            darkThumb.centerYAnchor.constraint(equalTo: button.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: darkThumb.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),

            checkmark.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            checkmark.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            checkmark.widthAnchor.constraint(equalToConstant: 16),
            checkmark.heightAnchor.constraint(equalToConstant: 16),
        ])

        return button
    }

    // MARK: - Background picker

    private func makeBackgroundPickerCard() -> UIView {
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.translatesAutoresizingMaskIntoConstraints = false

        let style = traitCollection.userInterfaceStyle
        for pair in ChristmasVariant.backgroundPairs {
            let imageName = style == .dark ? pair.dark : pair.light
            let thumb = makeBackgroundThumbnail(imageName: imageName)
            hStack.addArrangedSubview(thumb)
            backgroundThumbnails.append((imageName: imageName, view: thumb))
        }

        return makeHorizontalPickerCard(hStack: hStack, thumbHeight: 60)
    }

    private func makeBackgroundThumbnail(imageName: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = 10
        container.layer.borderWidth = 3
        container.layer.borderColor = (theme.christmas.backgroundImageName == imageName
            ? theme.christmas.accent : .clear).cgColor
        container.clipsToBounds = true

        let iv = UIImageView(image: UIImage(named: imageName))
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            var custom = theme.christmas
            custom.backgroundImageName = imageName
            custom.isCustomDefined = true
            theme.apply(custom)
        }, for: .touchUpInside)

        container.addSubview(iv)
        container.addSubview(button)

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 88),
            container.heightAnchor.constraint(equalToConstant: 60),
            iv.topAnchor.constraint(equalTo: container.topAnchor),
            iv.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            iv.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iv.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])

        return container
    }

    // MARK: - Icon picker

    private func makeIconPickerCard() -> UIView {
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.translatesAutoresizingMaskIntoConstraints = false

        for name in ChristmasVariant.iconNames {
            let thumb = makeIconThumbnail(name: name)
            hStack.addArrangedSubview(thumb)
            iconThumbnails.append((name: name, view: thumb))
        }

        return makeHorizontalPickerCard(hStack: hStack, thumbHeight: 60)
    }

    private func makeIconThumbnail(name: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .tertiarySystemGroupedBackground
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 3
        container.layer.borderColor = (theme.christmas.iconImageName == name
            ? theme.christmas.accent : .clear).cgColor

        let iv = UIImageView(image: UIImage(named: name))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            var custom = theme.christmas
            custom.iconImageName = name
            custom.isCustomDefined = true
            theme.apply(custom)
        }, for: .touchUpInside)

        container.addSubview(iv)
        container.addSubview(button)

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 60),
            container.heightAnchor.constraint(equalToConstant: 60),
            iv.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            iv.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            iv.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            iv.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])

        return container
    }

    // MARK: - Accent section

    private func makeAccentRow() -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Accent Color"
        label.translatesAutoresizingMaskIntoConstraints = false

        let colorWell = UIColorWell()
        colorWell.selectedColor = theme.christmas.accent
        colorWell.supportsAlpha = false
        colorWell.translatesAutoresizingMaskIntoConstraints = false
        colorWell.addAction(UIAction { [weak self, weak colorWell] _ in
            guard let self, let color = colorWell?.selectedColor else { return }
            var custom = theme.christmas
            custom.accent = color
            custom.isCustomDefined = true
            theme.apply(custom)
        }, for: .valueChanged)
        accentColorWell = colorWell

        container.addSubview(label)
        container.addSubview(colorWell)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 52),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            colorWell.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            colorWell.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])

        return container
    }

    private func makeResetButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Reset to Preset", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.backgroundColor = .secondarySystemGroupedBackground
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = !theme.christmas.isCustomDefined
        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let scheme = SystemColorScheme(traitCollection.userInterfaceStyle)
            let variant = ChristmasVariant.all.first { $0.id == theme.activeVariantID } ?? .classic
            theme.apply(variant: variant, for: scheme)
        }, for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 52),
        ])
        resetButton = button
        return button
    }

    // MARK: - Shared helpers

    private func makeHorizontalPickerCard(hStack: UIStackView, thumbHeight: CGFloat) -> UIView {
        let innerScroll = UIScrollView()
        innerScroll.showsHorizontalScrollIndicator = false
        innerScroll.translatesAutoresizingMaskIntoConstraints = false
        innerScroll.addSubview(hStack)

        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(innerScroll)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: thumbHeight + 24),

            innerScroll.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            innerScroll.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            innerScroll.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            innerScroll.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            hStack.topAnchor.constraint(equalTo: innerScroll.contentLayoutGuide.topAnchor),
            hStack.bottomAnchor.constraint(equalTo: innerScroll.contentLayoutGuide.bottomAnchor),
            hStack.leadingAnchor.constraint(equalTo: innerScroll.contentLayoutGuide.leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: innerScroll.contentLayoutGuide.trailingAnchor),
            hStack.heightAnchor.constraint(equalTo: innerScroll.frameLayoutGuide.heightAnchor),
        ])

        return card
    }

    private func makeThumbnail(imageName: String) -> UIImageView {
        let iv = UIImageView()
        iv.image = UIImage(named: imageName)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 6
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iv.widthAnchor.constraint(equalToConstant: 28),
            iv.heightAnchor.constraint(equalToConstant: 28),
        ])
        return iv
    }
}
