import ThemeKit
import UIKit

class ChristmasPickerViewController: UIViewController {

  // MARK: - State

  private var variantSchemeButtons: [SchemeCircleButton] = []
  private var backgroundThumbnails: [BackgroundThumbnailView] = []
  private var iconThumbnails: [IconThumbnailView] = []

  // MARK: - Views

  private var scrollView: UIScrollView!
  private var vStack: UIStackView!
  private var accentRow: ColorWellRow?
  private var resetButton: UIButton?

  // MARK: - Dependencies

  private let theme: Theme

  // MARK: - Init

  init(theme: Theme) {
    self.theme = theme
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    initializeViewAppearance()
    setupScrollView()
    setupAppearanceSection()
    setupPresetsSection()
    setupBackgroundSection()
    setupIconSection()
    setupAccentSection()
    setupResetButton()
    observeTheme()
  }

  // MARK: - Appearance

  private func initializeViewAppearance() {
    view.backgroundColor = .systemGroupedBackground
    if let sheet = sheetPresentationController {
      sheet.detents = [.medium(), .large()]
      sheet.prefersGrabberVisible = true
    }
  }

  // MARK: - Setup

  private func setupScrollView() {
    scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false

    vStack = UIStackView()
    vStack.axis = .vertical
    vStack.spacing = 12
    vStack.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(scrollView)
    scrollView.addSubview(vStack)

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

      vStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
      vStack.bottomAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
      vStack.leadingAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
      vStack.trailingAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
      vStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
    ])
  }

  private func setupAppearanceSection() {
    vStack.addArrangedSubview(makeSectionLabel("Appearance"))
    vStack.addArrangedSubview(FollowSystemRow(isOn: theme.followsSystem) { [weak self] isOn in
      self?.theme.followsSystem = isOn
    })
  }

  private func setupPresetsSection() {
    vStack.addArrangedSubview(makeSectionLabel("Presets"))
    for variant in ChristmasVariant.all {
      let row = VariantRowView(variant: variant) { [weak self] scheme in
        guard let self else { return }
        theme.apply(variant: variant, for: scheme)
      }
      variantSchemeButtons.append(contentsOf: [row.lightCircle, row.darkCircle])
      vStack.addArrangedSubview(row)
    }
  }

  private func setupBackgroundSection() {
    let card = HorizontalPickerCard(thumbHeight: 60)
    let style = traitCollection.userInterfaceStyle
    for pair in ChristmasVariant.backgroundPairs {
      let imageName = style == .dark ? pair.dark : pair.light
      let thumb = BackgroundThumbnailView(imageName: imageName, pair: pair) { [weak self] in
        guard let self else { return }
        var custom = theme.christmas
        custom.backgroundImageName = imageName
        theme.merge(custom)
      }
      card.addThumb(thumb)
      backgroundThumbnails.append(thumb)
    }
    vStack.addArrangedSubview(makeSectionLabel("Background"))
    vStack.addArrangedSubview(card)
  }

  private func setupIconSection() {
    let card = HorizontalPickerCard(thumbHeight: 60)
    for name in ChristmasVariant.iconNames {
      let thumb = IconThumbnailView(name: name) { [weak self] in
        guard let self else { return }
        var custom = theme.christmas
        custom.iconImageName = name
        theme.merge(custom)
      }
      card.addThumb(thumb)
      iconThumbnails.append(thumb)
    }
    vStack.addArrangedSubview(makeSectionLabel("Icon"))
    vStack.addArrangedSubview(card)
  }

  private func setupAccentSection() {
    let row = ColorWellRow(title: "Accent Color", color: theme.christmas.accent) { [weak self] color in
      guard let self else { return }
      var custom = theme.christmas
      custom.accent = color
      theme.merge(custom)
    }
    accentRow = row
    vStack.addArrangedSubview(makeSectionLabel("Accent"))
    vStack.addArrangedSubview(row)
  }

  private func setupResetButton() {
    let button = UIButton(type: .system)
    button.setTitle("Reset to Preset", for: .normal)
    button.setTitleColor(.systemRed, for: .normal)
    button.backgroundColor = .secondarySystemGroupedBackground
    button.layer.cornerRadius = 12
    button.translatesAutoresizingMaskIntoConstraints = false

    let preset = (ChristmasVariant.all.first { $0.id == theme.activeVariantID } ?? .classic)
      .value(for: theme.christmas.colorScheme)
    button.isHidden = !theme.christmas.compare(to: preset)

    button.addAction(
      UIAction { [weak self] _ in
        guard let self else { return }
        let variant = ChristmasVariant.all.first { $0.id == theme.activeVariantID } ?? .classic
        theme.apply(variant: variant, for: theme.christmas.colorScheme)
      }, for: .touchUpInside)

    NSLayoutConstraint.activate([button.heightAnchor.constraint(equalToConstant: 52)])

    vStack.addArrangedSubview(button)
    resetButton = button
  }

  // MARK: - Theme observation

  private func observeTheme() {
    withObservationTracking {
      let christmas = theme.christmas
      updateVariantSchemeButtons(christmas)
      updateBackgroundThumbnails(christmas)
      updateIconThumbnails(christmas)
      updateAccentRow(christmas)
      updateResetButton(christmas)
    } onChange: { [weak self] in
      Task { @MainActor [weak self] in self?.observeTheme() }
    }
  }

  private func updateVariantSchemeButtons(_ christmas: ChristmasTheme) {
    for button in variantSchemeButtons {
      let isActive = !theme.followsSystem
        && theme.activeVariantID == button.variantID
        && christmas.colorScheme == button.scheme
      let accent = (ChristmasVariant.all.first { $0.id == button.variantID } ?? .classic)
        .value(for: button.scheme).accent
      button.configure(isActive: isActive, accent: accent)
    }
  }

  private func updateBackgroundThumbnails(_ christmas: ChristmasTheme) {
    for thumb in backgroundThumbnails {
      let isSelected = christmas.backgroundImageName == thumb.pair.light
        || christmas.backgroundImageName == thumb.pair.dark
      thumb.configure(isSelected: isSelected, accent: christmas.accent, scheme: christmas.colorScheme)
    }
  }

  private func updateIconThumbnails(_ christmas: ChristmasTheme) {
    for thumb in iconThumbnails {
      thumb.configure(isSelected: christmas.iconImageName == thumb.iconName, accent: christmas.accent)
    }
  }

  private func updateAccentRow(_ christmas: ChristmasTheme) {
    accentRow?.configure(color: christmas.accent)
  }

  private func updateResetButton(_ christmas: ChristmasTheme) {
    let preset = (ChristmasVariant.all.first { $0.id == theme.activeVariantID } ?? .classic)
      .value(for: christmas.colorScheme)
    resetButton?.isHidden = !christmas.compare(to: preset)
  }

  // MARK: - Helpers

  private func makeSectionLabel(_ text: String) -> UILabel {
    let label = UILabel()
    label.text = text.uppercased()
    label.font = .systemFont(ofSize: 13, weight: .semibold)
    label.textColor = .secondaryLabel
    return label
  }
}
