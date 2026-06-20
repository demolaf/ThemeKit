import ThemeKit
import UIKit

class ColorsVariantRowView: UIView {
  let lightCircle: ColorsSchemeCircleButton
  let darkCircle: ColorsSchemeCircleButton

  init(variant: AppColorsVariant, onScheme: @escaping (SystemColorScheme) -> Void) {
    lightCircle = ColorsSchemeCircleButton(variant: variant, scheme: .light)
    darkCircle = ColorsSchemeCircleButton(variant: variant, scheme: .dark)
    super.init(frame: .zero)
    setupView(variant: variant, onScheme: onScheme)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  private func setupView(variant: AppColorsVariant, onScheme: @escaping (SystemColorScheme) -> Void) {
    backgroundColor = .secondarySystemGroupedBackground
    layer.cornerRadius = 12
    translatesAutoresizingMaskIntoConstraints = false

    let nameLabel = UILabel()
    nameLabel.text = variant.name
    nameLabel.translatesAutoresizingMaskIntoConstraints = false

    lightCircle.addAction(UIAction { _ in onScheme(.light) }, for: .touchUpInside)
    darkCircle.addAction(UIAction { _ in onScheme(.dark) }, for: .touchUpInside)

    addSubview(nameLabel)
    addSubview(lightCircle)
    addSubview(darkCircle)

    NSLayoutConstraint.activate([
      heightAnchor.constraint(equalToConstant: 56),

      nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

      darkCircle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      darkCircle.centerYAnchor.constraint(equalTo: centerYAnchor),
      darkCircle.widthAnchor.constraint(equalToConstant: 28),
      darkCircle.heightAnchor.constraint(equalToConstant: 28),

      lightCircle.trailingAnchor.constraint(equalTo: darkCircle.leadingAnchor, constant: -16),
      lightCircle.centerYAnchor.constraint(equalTo: centerYAnchor),
      lightCircle.widthAnchor.constraint(equalToConstant: 28),
      lightCircle.heightAnchor.constraint(equalToConstant: 28),
    ])
  }
}
