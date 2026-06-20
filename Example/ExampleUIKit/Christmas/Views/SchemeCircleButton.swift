import ThemeKit
import UIKit

class SchemeCircleButton: UIButton {
  private var symbolView: UIImageView!

  let variantID: String
  let scheme: SystemColorScheme

  init(variant: ChristmasVariant, scheme: SystemColorScheme) {
    self.variantID = variant.id
    self.scheme = scheme
    super.init(frame: .zero)
    setupButton()
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  private func setupButton() {
    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = .secondarySystemFill
    layer.cornerRadius = 14
    layer.borderWidth = 1.5
    layer.borderColor = scheme == .light ? UIColor.white.cgColor : UIColor.black.cgColor

    let symbolName = scheme == .light ? "sun.max.fill" : "moon.fill"
    let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
    symbolView = UIImageView(image: UIImage(systemName: symbolName, withConfiguration: config))
    symbolView.tintColor = .label
    symbolView.contentMode = .scaleAspectFit
    symbolView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(symbolView)

    NSLayoutConstraint.activate([
      symbolView.centerXAnchor.constraint(equalTo: centerXAnchor),
      symbolView.centerYAnchor.constraint(equalTo: centerYAnchor),
      symbolView.widthAnchor.constraint(equalToConstant: 16),
      symbolView.heightAnchor.constraint(equalToConstant: 16),
    ])
  }

  func configure(isActive: Bool, accent: UIColor) {
    layer.borderWidth = isActive ? 3 : 1.5
    layer.borderColor = isActive
      ? accent.cgColor
      : (scheme == .light ? UIColor.white.cgColor : UIColor.black.cgColor)
    symbolView.tintColor = isActive ? accent : .label
  }
}
