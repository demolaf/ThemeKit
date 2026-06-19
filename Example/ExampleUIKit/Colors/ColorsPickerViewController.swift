import ThemeKit
import UIKit

class ColorsPickerViewController: UIViewController {
  private let theme: Theme
  private var variantSchemeViews: [(
    variantID: String, scheme: SystemColorScheme, circle: UIButton, checkmark: UIImageView
  )] = []
  private var tintColorWell: UIColorWell?
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
    for variant in AppColorsVariant.all {
      vStack.addArrangedSubview(makeVariantRow(for: variant))
    }
    vStack.addArrangedSubview(makeSectionLabel("Custom"))
    vStack.addArrangedSubview(makeTintRow())
    vStack.addArrangedSubview(makeResetButton())
  }

  private func observeTheme() {
    withObservationTracking {
      let colors = theme.colors
      let tint = colors.tint
      let preset = (AppColorsVariant.all.first { $0.id == theme.activeVariantID } ?? .default)
        .value(for: colors.colorScheme)

      for entry in variantSchemeViews {
        let isActive =
          !theme.followsSystem && theme.activeVariantID == entry.variantID
          && colors.colorScheme == entry.scheme
        entry.circle.layer.borderWidth = isActive ? 3 : 1.5
        entry.circle.layer.borderColor =
          isActive
          ? tint.cgColor
          : (entry.scheme == .light ? UIColor.white.cgColor : UIColor.black.cgColor)
        entry.checkmark.isHidden = !isActive
        if isActive { entry.checkmark.tintColor = .white }
      }
      tintColorWell?.selectedColor = tint
      resetButton?.isHidden = !colors.compare(to: preset)
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
      vStack.bottomAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
      vStack.leadingAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
      vStack.trailingAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
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
    toggle.addAction(
      UIAction { [weak self, weak toggle] _ in
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

  private func makeVariantRow(for variant: AppColorsVariant) -> UIView {
    let container = UIView()
    container.backgroundColor = .secondarySystemGroupedBackground
    container.layer.cornerRadius = 12
    container.translatesAutoresizingMaskIntoConstraints = false

    let nameLabel = UILabel()
    nameLabel.text = variant.name
    nameLabel.translatesAutoresizingMaskIntoConstraints = false

    let lightCircle = makeSchemeCircle(variant: variant, scheme: .light)
    let darkCircle = makeSchemeCircle(variant: variant, scheme: .dark)

    container.addSubview(nameLabel)
    container.addSubview(lightCircle)
    container.addSubview(darkCircle)

    NSLayoutConstraint.activate([
      container.heightAnchor.constraint(equalToConstant: 56),

      nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
      nameLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

      darkCircle.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
      darkCircle.centerYAnchor.constraint(equalTo: container.centerYAnchor),
      darkCircle.widthAnchor.constraint(equalToConstant: 28),
      darkCircle.heightAnchor.constraint(equalToConstant: 28),

      lightCircle.trailingAnchor.constraint(equalTo: darkCircle.leadingAnchor, constant: -16),
      lightCircle.centerYAnchor.constraint(equalTo: container.centerYAnchor),
      lightCircle.widthAnchor.constraint(equalToConstant: 28),
      lightCircle.heightAnchor.constraint(equalToConstant: 28),
    ])

    return container
  }

  private func makeSchemeCircle(variant: AppColorsVariant, scheme: SystemColorScheme) -> UIButton {
    let colors = variant.value(for: scheme)
    let isActive =
      !theme.followsSystem && theme.activeVariantID == variant.id
      && theme.colors.colorScheme == scheme

    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.backgroundColor = colors.tint
    button.layer.cornerRadius = 14
    button.layer.borderWidth = isActive ? 3 : 1.5
    button.layer.borderColor =
      isActive
      ? theme.colors.tint.cgColor
      : (scheme == .light ? UIColor.white.cgColor : UIColor.black.cgColor)
    button.clipsToBounds = true

    let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
    checkmark.tintColor = .white
    checkmark.contentMode = .scaleAspectFit
    checkmark.translatesAutoresizingMaskIntoConstraints = false
    checkmark.isHidden = !isActive
    button.addSubview(checkmark)

    NSLayoutConstraint.activate([
      checkmark.centerXAnchor.constraint(equalTo: button.centerXAnchor),
      checkmark.centerYAnchor.constraint(equalTo: button.centerYAnchor),
      checkmark.widthAnchor.constraint(equalToConstant: 11),
      checkmark.heightAnchor.constraint(equalToConstant: 11),
    ])

    button.addAction(
      UIAction { [weak self] _ in
        guard let self else { return }
        theme.apply(variant: variant, for: scheme)
      }, for: .touchUpInside)

    variantSchemeViews.append((variantID: variant.id, scheme: scheme, circle: button, checkmark: checkmark))

    return button
  }

  private func makeTintRow() -> UIView {
    let container = UIView()
    container.backgroundColor = .secondarySystemGroupedBackground
    container.layer.cornerRadius = 12
    container.translatesAutoresizingMaskIntoConstraints = false

    let label = UILabel()
    label.text = "Tint Color"
    label.translatesAutoresizingMaskIntoConstraints = false

    let colorWell = UIColorWell()
    colorWell.selectedColor = theme.colors.tint
    colorWell.supportsAlpha = false
    colorWell.translatesAutoresizingMaskIntoConstraints = false
    colorWell.addAction(
      UIAction { [weak self, weak colorWell] _ in
        guard let self, let color = colorWell?.selectedColor else { return }
        var custom = theme.colors
        custom.tint = color
        theme.merge(custom)
      }, for: .valueChanged)
    tintColorWell = colorWell

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
    let preset = (AppColorsVariant.all.first { $0.id == theme.activeVariantID } ?? .default)
      .value(for: theme.colors.colorScheme)
    button.isHidden = !theme.colors.compare(to: preset)
    button.addAction(
      UIAction { [weak self] _ in
        guard let self else { return }
        let variant = AppColorsVariant.all.first { $0.id == theme.activeVariantID } ?? .default
        theme.apply(variant: variant, for: theme.colors.colorScheme)
      }, for: .touchUpInside)
    NSLayoutConstraint.activate([
      button.heightAnchor.constraint(equalToConstant: 52)
    ])
    resetButton = button
    return button
  }
}
