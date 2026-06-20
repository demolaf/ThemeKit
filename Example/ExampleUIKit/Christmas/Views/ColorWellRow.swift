import UIKit

class ColorWellRow: UIView {
  private var colorWell: UIColorWell!

  init(title: String, color: UIColor, onColorChange: @escaping (UIColor) -> Void) {
    super.init(frame: .zero)
    setupView(title: title, color: color, onColorChange: onColorChange)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  private func setupView(title: String, color: UIColor, onColorChange: @escaping (UIColor) -> Void) {
    backgroundColor = .secondarySystemGroupedBackground
    layer.cornerRadius = 12
    translatesAutoresizingMaskIntoConstraints = false

    let label = UILabel()
    label.text = title
    label.translatesAutoresizingMaskIntoConstraints = false

    colorWell = UIColorWell()
    colorWell.selectedColor = color
    colorWell.supportsAlpha = false
    colorWell.translatesAutoresizingMaskIntoConstraints = false
    colorWell.addAction(
      UIAction { [weak self] _ in
        guard let self, let color = colorWell.selectedColor else { return }
        onColorChange(color)
      }, for: .valueChanged)

    addSubview(label)
    addSubview(colorWell)

    NSLayoutConstraint.activate([
      heightAnchor.constraint(equalToConstant: 52),
      label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      label.centerYAnchor.constraint(equalTo: centerYAnchor),
      colorWell.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      colorWell.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])
  }

  func configure(color: UIColor) {
    colorWell.selectedColor = color
  }
}
