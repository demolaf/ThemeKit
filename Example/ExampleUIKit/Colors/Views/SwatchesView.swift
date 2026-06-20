import UIKit

class SwatchesView: UIView {
  private var tintColorView: UIView!
  private var backgroundColorView: UIView!
  private var containerColorView: UIView!

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  private func setupView() {
    translatesAutoresizingMaskIntoConstraints = false

    tintColorView = makeColorView()
    backgroundColorView = makeColorView()
    containerColorView = makeColorView()

    let hStack = UIStackView(arrangedSubviews: [
      makeSwatchItem(colorView: tintColorView, label: "Tint"),
      makeSwatchItem(colorView: backgroundColorView, label: "Background"),
      makeSwatchItem(colorView: containerColorView, label: "Container"),
    ])
    hStack.axis = .horizontal
    hStack.distribution = .fillEqually
    hStack.spacing = 12
    hStack.translatesAutoresizingMaskIntoConstraints = false

    addSubview(hStack)

    NSLayoutConstraint.activate([
      hStack.topAnchor.constraint(equalTo: topAnchor),
      hStack.bottomAnchor.constraint(equalTo: bottomAnchor),
      hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
      hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
    ])
  }

  private func makeColorView() -> UIView {
    let v = UIView()
    v.layer.cornerRadius = 12
    v.layer.borderWidth = 0.5
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }

  private func makeSwatchItem(colorView: UIView, label: String) -> UIView {
    let container = UIView()

    let titleLabel = UILabel()
    titleLabel.text = label
    titleLabel.font = .systemFont(ofSize: 12)
    titleLabel.textColor = .secondaryLabel
    titleLabel.textAlignment = .center
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    container.addSubview(colorView)
    container.addSubview(titleLabel)

    NSLayoutConstraint.activate([
      colorView.topAnchor.constraint(equalTo: container.topAnchor),
      colorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      colorView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      colorView.heightAnchor.constraint(equalToConstant: 60),

      titleLabel.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 6),
      titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])

    return container
  }

  func configure(tint: UIColor, background: UIColor, container: UIColor) {
    let borderColor = UIColor.separator.cgColor
    tintColorView.backgroundColor = tint
    backgroundColorView.backgroundColor = background
    containerColorView.backgroundColor = container
    tintColorView.layer.borderColor = borderColor
    backgroundColorView.layer.borderColor = borderColor
    containerColorView.layer.borderColor = borderColor
  }
}
