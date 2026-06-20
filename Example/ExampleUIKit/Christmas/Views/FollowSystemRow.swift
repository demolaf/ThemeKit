import UIKit

class FollowSystemRow: UIView {
  private var toggle: UISwitch!

  init(isOn: Bool, onToggle: @escaping (Bool) -> Void) {
    super.init(frame: .zero)
    setupView(isOn: isOn, onToggle: onToggle)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  private func setupView(isOn: Bool, onToggle: @escaping (Bool) -> Void) {
    backgroundColor = .secondarySystemGroupedBackground
    layer.cornerRadius = 12
    translatesAutoresizingMaskIntoConstraints = false

    let label = UILabel()
    label.text = "Follow System Appearance"
    label.translatesAutoresizingMaskIntoConstraints = false

    toggle = UISwitch()
    toggle.isOn = isOn
    toggle.translatesAutoresizingMaskIntoConstraints = false
    toggle.addAction(
      UIAction { [weak self] _ in
        guard let self else { return }
        onToggle(toggle.isOn)
      }, for: .valueChanged)

    addSubview(label)
    addSubview(toggle)

    NSLayoutConstraint.activate([
      heightAnchor.constraint(equalToConstant: 52),
      label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      label.centerYAnchor.constraint(equalTo: centerYAnchor),
      toggle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      toggle.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])
  }
}
