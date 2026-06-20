import ThemeKit
import UIKit

class VariantRowView: UIView {
  let lightCircle: SchemeCircleButton
  let darkCircle: SchemeCircleButton

  init(variant: ChristmasVariant, onScheme: @escaping (SystemColorScheme) -> Void) {
    lightCircle = SchemeCircleButton(variant: variant, scheme: .light)
    darkCircle = SchemeCircleButton(variant: variant, scheme: .dark)
    super.init(frame: .zero)
    setupView(variant: variant, onScheme: onScheme)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  private func setupView(variant: ChristmasVariant, onScheme: @escaping (SystemColorScheme) -> Void) {
    backgroundColor = .secondarySystemGroupedBackground
    layer.cornerRadius = 12
    translatesAutoresizingMaskIntoConstraints = false

    let lightThumb = makeThumbnail(imageName: variant.light.backgroundImageName)
    let darkThumb = makeThumbnail(imageName: variant.dark.backgroundImageName)

    let nameLabel = UILabel()
    nameLabel.text = variant.name
    nameLabel.translatesAutoresizingMaskIntoConstraints = false

    lightCircle.addAction(UIAction { _ in onScheme(.light) }, for: .touchUpInside)
    darkCircle.addAction(UIAction { _ in onScheme(.dark) }, for: .touchUpInside)

    addSubview(lightThumb)
    addSubview(darkThumb)
    addSubview(nameLabel)
    addSubview(lightCircle)
    addSubview(darkCircle)

    NSLayoutConstraint.activate([
      heightAnchor.constraint(equalToConstant: 56),

      lightThumb.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      lightThumb.centerYAnchor.constraint(equalTo: centerYAnchor),

      darkThumb.leadingAnchor.constraint(equalTo: lightThumb.trailingAnchor, constant: -8),
      darkThumb.centerYAnchor.constraint(equalTo: centerYAnchor),

      nameLabel.leadingAnchor.constraint(equalTo: darkThumb.trailingAnchor, constant: 12),
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

  private func makeThumbnail(imageName: String) -> UIImageView {
    let iv = UIImageView()
    iv.image = UIImage(named: imageName)
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.layer.cornerRadius = 6
    iv.layer.borderWidth = 2
    iv.layer.borderColor = UIColor.white.cgColor
    iv.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      iv.widthAnchor.constraint(equalToConstant: 28),
      iv.heightAnchor.constraint(equalToConstant: 28),
    ])
    return iv
  }
}
