import UIKit
import ThemeKit
import ThemeKitUIKit

class ChristmasViewController: UIViewController {
    private let theme = Theme()
    private var applier: ThemeApplier<ChristmasVariant>?

    private let wishes = ["Joy", "Peace", "Hope", "Love", "Warmth"]

    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let heroCard: UIVisualEffectView = {
        let ev = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        ev.layer.cornerRadius = 20
        ev.clipsToBounds = true
        ev.translatesAutoresizingMaskIntoConstraints = false
        return ev
    }()

    private let heroIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let heroTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Merry Christmas"
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let wishesCard: UIVisualEffectView = {
        let ev = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        ev.layer.cornerRadius = 16
        ev.clipsToBounds = true
        ev.translatesAutoresizingMaskIntoConstraints = false
        return ev
    }()

    private let wishesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private var wishIconImageViews: [UIImageView] = []
    private var wishLabels: [UILabel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViewAppearance()
        initializeSubviews()
        setupNavigationBarItems()
        observeTheme()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard applier == nil else { return }
        let a = ThemeApplier(theme: theme, default: .classic, available: ChristmasVariant.all)
        a.onAppear()
        a.onChangeOfThemeState()
        a.onChangeOfSystemUserInterfaceStyle(window: view.window)
        applier = a
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyConstraints()
    }

    private func initializeViewAppearance() {
        title = "Christmas"
        navigationItem.largeTitleDisplayMode = .never
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }

    private func initializeSubviews() {
        view.addSubview(backgroundImageView)

        heroCard.contentView.addSubview(heroIconImageView)
        heroCard.contentView.addSubview(heroTitleLabel)
        view.addSubview(heroCard)

        for (index, wish) in wishes.enumerated() {
            let (rowView, iconIV, label) = makeWishRow(text: wish)
            wishesStack.addArrangedSubview(rowView)
            wishIconImageViews.append(iconIV)
            wishLabels.append(label)
            if index < wishes.count - 1 {
                wishesStack.addArrangedSubview(makeDivider())
            }
        }
        wishesCard.contentView.addSubview(wishesStack)
        view.addSubview(wishesCard)
    }

    private func setupNavigationBarItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "paintbrush.pointed"),
            primaryAction: UIAction { [weak self] _ in
                guard let self else { return }
                let pickerVC = ChristmasPickerViewController(theme: theme)
                present(pickerVC, animated: true)
            }
        )
    }

    private func observeTheme() {
        withObservationTracking {
            let christmas = theme.christmas
            backgroundImageView.image = UIImage(named: christmas.backgroundImageName)
            heroIconImageView.image = UIImage(named: christmas.iconImageName)
            heroTitleLabel.textColor = christmas.accent
            heroTitleLabel.font = christmas.titleFont
            navigationItem.rightBarButtonItem?.tintColor = christmas.accent
            let bodyFont = christmas.bodyFont
            for iv in wishIconImageViews { iv.image = UIImage(named: christmas.iconImageName) }
            for label in wishLabels { label.font = bodyFont }
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.observeTheme()
            }
        }
    }

    private func applyConstraints() {
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            heroCard.topAnchor.constraint(equalTo: safe.topAnchor, constant: 32),
            heroCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            heroCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            heroIconImageView.topAnchor.constraint(equalTo: heroCard.contentView.topAnchor, constant: 24),
            heroIconImageView.centerXAnchor.constraint(equalTo: heroCard.contentView.centerXAnchor),
            heroIconImageView.widthAnchor.constraint(equalToConstant: 80),
            heroIconImageView.heightAnchor.constraint(equalToConstant: 80),

            heroTitleLabel.topAnchor.constraint(equalTo: heroIconImageView.bottomAnchor, constant: 12),
            heroTitleLabel.leadingAnchor.constraint(equalTo: heroCard.contentView.leadingAnchor, constant: 24),
            heroTitleLabel.trailingAnchor.constraint(equalTo: heroCard.contentView.trailingAnchor, constant: -24),
            heroTitleLabel.bottomAnchor.constraint(equalTo: heroCard.contentView.bottomAnchor, constant: -24),

            wishesCard.topAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: 24),
            wishesCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            wishesCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            wishesStack.topAnchor.constraint(equalTo: wishesCard.contentView.topAnchor),
            wishesStack.bottomAnchor.constraint(equalTo: wishesCard.contentView.bottomAnchor),
            wishesStack.leadingAnchor.constraint(equalTo: wishesCard.contentView.leadingAnchor),
            wishesStack.trailingAnchor.constraint(equalTo: wishesCard.contentView.trailingAnchor),
        ])
    }

    private func makeWishRow(text: String) -> (UIView, UIImageView, UILabel) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(iv)
        container.addSubview(label)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 52),
            iv.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            iv.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iv.widthAnchor.constraint(equalToConstant: 24),
            iv.heightAnchor.constraint(equalToConstant: 24),
            label.leadingAnchor.constraint(equalTo: iv.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
        ])

        return (container, iv, label)
    }

    private func makeDivider() -> UIView {
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        let line = UIView()
        line.backgroundColor = .separator
        line.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(line)
        NSLayoutConstraint.activate([
            wrapper.heightAnchor.constraint(equalToConstant: 0.5),
            line.heightAnchor.constraint(equalToConstant: 0.5),
            line.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 56),
            line.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            line.topAnchor.constraint(equalTo: wrapper.topAnchor),
        ])
        return wrapper
    }
}
