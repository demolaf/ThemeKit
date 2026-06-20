import UIKit

class BackgroundThumbnailView: UIView {
  let pair: (light: String, dark: String)

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

    let iv = UIImageView(image: UIImage(named: imageName))
    iv.contentMode = .scaleAspectFill
    iv.translatesAutoresizingMaskIntoConstraints = false

    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addAction(UIAction { _ in onTap() }, for: .touchUpInside)

    addSubview(iv)
    addSubview(button)

    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: 88),
      heightAnchor.constraint(equalToConstant: 60),
      iv.topAnchor.constraint(equalTo: topAnchor),
      iv.bottomAnchor.constraint(equalTo: bottomAnchor),
      iv.leadingAnchor.constraint(equalTo: leadingAnchor),
      iv.trailingAnchor.constraint(equalTo: trailingAnchor),
      button.topAnchor.constraint(equalTo: topAnchor),
      button.bottomAnchor.constraint(equalTo: bottomAnchor),
      button.leadingAnchor.constraint(equalTo: leadingAnchor),
      button.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }

  func configure(isSelected: Bool, accent: UIColor) {
    layer.borderColor = (isSelected ? accent : .clear).cgColor
  }
}
