import ThemeKit
import UIKit

class ColorsPickerViewController: UIViewController {
  private let theme: Theme

  private var variantSchemeButtons: [ColorsSchemeCircleButton] = []
  private var tintRow: ColorWellRow?
  private var resetButton: UIButton?

  private var scrollView: UIScrollView!
  private var vStack: UIStackView!

  init(theme: Theme) {
    self.theme = theme
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func viewDidLoad() {
    super.viewDidLoad()
    initializeViewAppearance()
    setupScrollView()
    setupAppearanceSection()
    setupPresetsSection()
    setupCustomSection()
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
    for variant in AppColorsVariant.all {
      let row = ColorsVariantRowView(variant: variant) { [weak self] scheme in
        guard let self else { return }
        theme.apply(variant: variant, for: scheme)
      }
      variantSchemeButtons.append(contentsOf: [row.lightCircle, row.darkCircle])
      vStack.addArrangedSubview(row)
    }
  }

  private func setupCustomSection() {
    let row = ColorWellRow(title: "Tint Color", color: theme.colors.tint) { [weak self] color in
      guard let self else { return }
      var custom = theme.colors
      custom.tint = color
      theme.merge(custom)
    }
    tintRow = row
    vStack.addArrangedSubview(makeSectionLabel("Custom"))
    vStack.addArrangedSubview(row)
  }

  private func setupResetButton() {
    let button = UIButton(type: .system)
    button.setTitle("Reset to Preset", for: .normal)
    button.setTitleColor(.systemRed, for: .normal)
    button.backgroundColor = .secondarySystemGroupedBackground
    button.layer.cornerRadius = 12
    button.translatesAutoresizingMaskIntoConstraints = false

    let preset = (AppColorsVariant.all.first { $0.id == theme.activeVariantID } ?? .default)
      .value(for: theme.colors.colorScheme)
    button.isHidden = !theme.colors.compare(to: preset)

    button.addAction(
      UIAction { [weak self] _ in
        guard let self else { return }
        let variant = AppColorsVariant.all.first { $0.id == theme.activeVariantID } ?? .default
        theme.apply(variant: variant, for: theme.colors.colorScheme)
      }, for: .touchUpInside)

    NSLayoutConstraint.activate([button.heightAnchor.constraint(equalToConstant: 52)])

    vStack.addArrangedSubview(button)
    resetButton = button
  }

  // MARK: - Theme observation

  private func observeTheme() {
    withObservationTracking {
      let colors = theme.colors
      updateVariantSchemeButtons(colors)
      updateTintRow(colors)
      updateResetButton(colors)
    } onChange: { [weak self] in
      Task { @MainActor [weak self] in self?.observeTheme() }
    }
  }

  private func updateVariantSchemeButtons(_ colors: AppColors) {
    for button in variantSchemeButtons {
      let isActive = !theme.followsSystem
        && theme.activeVariantID == button.variantID
        && colors.colorScheme == button.scheme
      button.configure(isActive: isActive, currentTint: colors.tint)
    }
  }

  private func updateTintRow(_ colors: AppColors) {
    tintRow?.configure(color: colors.tint)
  }

  private func updateResetButton(_ colors: AppColors) {
    let preset = (AppColorsVariant.all.first { $0.id == theme.activeVariantID } ?? .default)
      .value(for: colors.colorScheme)
    resetButton?.isHidden = !colors.compare(to: preset)
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
