import ThemeKit
import UIKit

class BackgroundThumbnailView: UIView {
  let pair: (light: String, dark: String)
  private var imageView: UIImageView!

  init(imageName: String, pair: (light: String, dark: String), onTap: @escaping () -> Void) {
    self.pair = pair
    super.init(frame: .zero)
    setupView(imageName: imageName, onTap: onTap)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  private func setupView(imageName: String, onTap: @escaping () -> Void) {
    translatesAutoresizingMaskIntoConstraints = false
    layer.cornerRadius = 10
    layer.borderWidth = 3
    layer.borderColor = UIColor.clear.cgColor
    clipsToBounds = true

    imageView = UIImageView(image: UIImage(named: imageName))
    imageView.contentMode = .scaleAspectFill
    imageView.translatesAutoresizingMaskIntoConstraints = false

    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addAction(UIAction { _ in onTap() }, for: .touchUpInside)

    addSubview(imageView)
    addSubview(button)

    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: 88),
      heightAnchor.constraint(equalToConstant: 60),
      imageView.topAnchor.constraint(equalTo: topAnchor),
      imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
      imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
      button.topAnchor.constraint(equalTo: topAnchor),
      button.bottomAnchor.constraint(equalTo: bottomAnchor),
      button.leadingAnchor.constraint(equalTo: leadingAnchor),
      button.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }

  func configure(isSelected: Bool, accent: UIColor, scheme: SystemColorScheme) {
    imageView.image = UIImage(named: scheme == .dark ? pair.dark : pair.light)
    layer.borderColor = (isSelected ? accent : accent.withAlphaComponent(0)).cgColor
  }
}
