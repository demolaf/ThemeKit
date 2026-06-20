import ThemeKit
import UIKit

class ColorsSchemeCircleButton: UIButton {
  private var checkmark: UIImageView!

  let variantID: String
  let scheme: SystemColorScheme

  init(variant: AppColorsVariant, scheme: SystemColorScheme) {
    self.variantID = variant.id
    self.scheme = scheme
    super.init(frame: .zero)
    setupButton(tint: variant.value(for: scheme).tint)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  private func setupButton(tint: UIColor) {
    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = tint
    layer.cornerRadius = 14
    layer.borderWidth = 1.5
    layer.borderColor = scheme == .light ? UIColor.white.cgColor : UIColor.black.cgColor
    clipsToBounds = true

    checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
    checkmark.tintColor = .white
    checkmark.contentMode = .scaleAspectFit
    checkmark.isHidden = true
    checkmark.translatesAutoresizingMaskIntoConstraints = false
    addSubview(checkmark)

    NSLayoutConstraint.activate([
      checkmark.centerXAnchor.constraint(equalTo: centerXAnchor),
      checkmark.centerYAnchor.constraint(equalTo: centerYAnchor),
      checkmark.widthAnchor.constraint(equalToConstant: 11),
      checkmark.heightAnchor.constraint(equalToConstant: 11),
    ])
  }

  func configure(isActive: Bool, currentTint: UIColor) {
    layer.borderWidth = isActive ? 3 : 1.5
    layer.borderColor = isActive
      ? currentTint.cgColor
      : (scheme == .light ? UIColor.white.cgColor : UIColor.black.cgColor)
    checkmark.isHidden = !isActive
  }
}
