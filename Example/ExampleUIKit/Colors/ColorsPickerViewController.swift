import UIKit
import ThemeKit

class ColorsPickerViewController: UIViewController {
    private let theme: Theme
    private var variantCheckmarks: [String: UIImageView] = [:]

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
        for variant in AppColorsVariant.all {
            vStack.addArrangedSubview(makeVariantRow(for: variant))
        }
    }

    private func observeTheme() {
        withObservationTracking {
            let tint = theme.colors.tint
            for (id, checkmark) in variantCheckmarks {
                checkmark.isHidden = theme.activeVariantID != id
                checkmark.tintColor = tint
            }
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.observeTheme()
            }
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

    private func makeVariantRow(for variant: AppColorsVariant) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = .secondarySystemGroupedBackground
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            theme.apply(variant: variant, for: SystemColorScheme(traitCollection.userInterfaceStyle))
        }, for: .touchUpInside)

        let lightCircle = makeColorCircle(variant.light.tint)
        let darkCircle = makeColorCircle(variant.dark.tint)

        let nameLabel = UILabel()
        nameLabel.text = variant.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
        checkmark.tintColor = theme.colors.tint
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        checkmark.isHidden = theme.activeVariantID != variant.id
        variantCheckmarks[variant.id] = checkmark

        button.addSubview(lightCircle)
        button.addSubview(darkCircle)
        button.addSubview(nameLabel)
        button.addSubview(checkmark)

        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 56),

            lightCircle.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            lightCircle.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            lightCircle.widthAnchor.constraint(equalToConstant: 28),
            lightCircle.heightAnchor.constraint(equalToConstant: 28),

            darkCircle.leadingAnchor.constraint(equalTo: lightCircle.trailingAnchor, constant: -8),
            darkCircle.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            darkCircle.widthAnchor.constraint(equalToConstant: 28),
            darkCircle.heightAnchor.constraint(equalToConstant: 28),

            nameLabel.leadingAnchor.constraint(equalTo: darkCircle.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),

            checkmark.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            checkmark.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            checkmark.widthAnchor.constraint(equalToConstant: 16),
            checkmark.heightAnchor.constraint(equalToConstant: 16),
        ])

        return button
    }

    private func makeColorCircle(_ color: UIColor) -> UIView {
        let v = UIView()
        v.backgroundColor = color
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.separator.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }
}
