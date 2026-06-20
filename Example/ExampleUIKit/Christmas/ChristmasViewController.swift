import ThemeKit
import ThemeKitUIKit
import UIKit

class ChristmasViewController: UIViewController {
  private let theme = Theme(suiteName: "com.themekit.example.christmas")
  private var applier: ThemeApplier<ChristmasVariant>?

  private let wishes = ["Joy", "Peace", "Hope", "Love", "Warmth"]

  private var backgroundImageView: UIImageView!
  private var heroCard: UIVisualEffectView!
  private var heroIconImageView: UIImageView!
  private var heroTitleLabel: UILabel!
  private var wishesCard: UIVisualEffectView!
  private var wishesStack: UIStackView!
  private var wishRows: [WishRowView] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    initializeViewAppearance()
    setupBackgroundImageView()
    setupHeroCard()
    setupWishesCard()
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

  // MARK: - Appearance

  private func initializeViewAppearance() {
    title = "Christmas"
    navigationItem.largeTitleDisplayMode = .never
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    navigationItem.standardAppearance = appearance
    navigationItem.scrollEdgeAppearance = appearance
    navigationItem.compactAppearance = appearance
  }

  // MARK: - Setup

  private func setupBackgroundImageView() {
    backgroundImageView = UIImageView()
    backgroundImageView.contentMode = .scaleAspectFill
    backgroundImageView.clipsToBounds = true
    backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(backgroundImageView)
    NSLayoutConstraint.activate([
      backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
      backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }

  private func setupHeroCard() {
    heroCard = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    heroCard.layer.cornerRadius = 20
    heroCard.clipsToBounds = true
    heroCard.translatesAutoresizingMaskIntoConstraints = false

    heroIconImageView = UIImageView()
    heroIconImageView.contentMode = .scaleAspectFit
    heroIconImageView.translatesAutoresizingMaskIntoConstraints = false

    heroTitleLabel = UILabel()
    heroTitleLabel.text = "Merry Christmas"
    heroTitleLabel.textAlignment = .center
    heroTitleLabel.translatesAutoresizingMaskIntoConstraints = false

    heroCard.contentView.addSubview(heroIconImageView)
    heroCard.contentView.addSubview(heroTitleLabel)
    view.addSubview(heroCard)

    let safe = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      heroCard.topAnchor.constraint(equalTo: safe.topAnchor, constant: 32),
      heroCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      heroCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

      heroIconImageView.topAnchor.constraint(
        equalTo: heroCard.contentView.topAnchor, constant: 24),
      heroIconImageView.centerXAnchor.constraint(
        equalTo: heroCard.contentView.centerXAnchor),
      heroIconImageView.widthAnchor.constraint(equalToConstant: 80),
      heroIconImageView.heightAnchor.constraint(equalToConstant: 80),

      heroTitleLabel.topAnchor.constraint(equalTo: heroIconImageView.bottomAnchor, constant: 12),
      heroTitleLabel.leadingAnchor.constraint(
        equalTo: heroCard.contentView.leadingAnchor, constant: 24),
      heroTitleLabel.trailingAnchor.constraint(
        equalTo: heroCard.contentView.trailingAnchor, constant: -24),
      heroTitleLabel.bottomAnchor.constraint(
        equalTo: heroCard.contentView.bottomAnchor, constant: -24),
    ])
  }

  private func setupWishesCard() {
    wishesCard = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    wishesCard.layer.cornerRadius = 16
    wishesCard.clipsToBounds = true
    wishesCard.translatesAutoresizingMaskIntoConstraints = false

    wishesStack = UIStackView()
    wishesStack.axis = .vertical
    wishesStack.spacing = 0
    wishesStack.translatesAutoresizingMaskIntoConstraints = false

    for (index, wish) in wishes.enumerated() {
      let row = WishRowView(text: wish)
      wishRows.append(row)
      wishesStack.addArrangedSubview(row)
      if index < wishes.count - 1 {
        wishesStack.addArrangedSubview(DividerView())
      }
    }

    wishesCard.contentView.addSubview(wishesStack)
    view.addSubview(wishesCard)

    NSLayoutConstraint.activate([
      wishesCard.topAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: 24),
      wishesCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      wishesCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

      wishesStack.topAnchor.constraint(equalTo: wishesCard.contentView.topAnchor),
      wishesStack.bottomAnchor.constraint(equalTo: wishesCard.contentView.bottomAnchor),
      wishesStack.leadingAnchor.constraint(equalTo: wishesCard.contentView.leadingAnchor),
      wishesStack.trailingAnchor.constraint(equalTo: wishesCard.contentView.trailingAnchor),
    ])
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

  // MARK: - Theme observation

  private func observeTheme() {
    withObservationTracking {
      let christmas = theme.christmas
      backgroundImageView.image = UIImage(named: christmas.backgroundImageName)
      heroIconImageView.image = UIImage(named: christmas.iconImageName)
      heroTitleLabel.textColor = christmas.accent
      heroTitleLabel.font = christmas.titleFont
      navigationItem.rightBarButtonItem?.tintColor = christmas.accent
      for row in wishRows {
        row.configure(iconName: christmas.iconImageName, font: christmas.bodyFont)
      }
    } onChange: { [weak self] in
      Task { @MainActor [weak self] in
        self?.observeTheme()
      }
    }
  }
}
