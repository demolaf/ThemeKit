import UIKit

class WishRowView: UIView {
  private(set) var iconImageView: UIImageView!
  private(set) var label: UILabel!

  init(text: String) {
    super.init(frame: .zero)
    setupView(text: text)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  private func setupView(text: String) {
    translatesAutoresizingMaskIntoConstraints = false

    iconImageView = UIImageView()
    iconImageView.contentMode = .scaleAspectFit
    iconImageView.translatesAutoresizingMaskIntoConstraints = false

    label = UILabel()
    label.text = text
    label.translatesAutoresizingMaskIntoConstraints = false

    addSubview(iconImageView)
    addSubview(label)

    NSLayoutConstraint.activate([
      heightAnchor.constraint(equalToConstant: 52),
      iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
      iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
      iconImageView.widthAnchor.constraint(equalToConstant: 24),
      iconImageView.heightAnchor.constraint(equalToConstant: 24),
      label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
      label.centerYAnchor.constraint(equalTo: centerYAnchor),
      label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
    ])
  }

  func configure(iconName: String, font: UIFont) {
    iconImageView.image = UIImage(named: iconName)
    label.font = font
  }
}
