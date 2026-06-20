import UIKit

class IconThumbnailView: UIView {
  let iconName: String

  init(name: String, onTap: @escaping () -> Void) {
    self.iconName = name
    super.init(frame: .zero)
    setupView(name: name, onTap: onTap)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  private func setupView(name: String, onTap: @escaping () -> Void) {
    backgroundColor = .tertiarySystemGroupedBackground
    translatesAutoresizingMaskIntoConstraints = false
    layer.cornerRadius = 12
    layer.borderWidth = 3
    layer.borderColor = UIColor.clear.cgColor

    let iv = UIImageView(image: UIImage(named: name))
    iv.contentMode = .scaleAspectFit
    iv.translatesAutoresizingMaskIntoConstraints = false

    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addAction(UIAction { _ in onTap() }, for: .touchUpInside)

    addSubview(iv)
    addSubview(button)

    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: 60),
      heightAnchor.constraint(equalToConstant: 60),
      iv.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      iv.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
      iv.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
      iv.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
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
