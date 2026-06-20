import UIKit

class DividerView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  private func setupView() {
    translatesAutoresizingMaskIntoConstraints = false
    let line = UIView()
    line.backgroundColor = .separator
    line.translatesAutoresizingMaskIntoConstraints = false
    addSubview(line)
    NSLayoutConstraint.activate([
      heightAnchor.constraint(equalToConstant: 0.5),
      line.heightAnchor.constraint(equalToConstant: 0.5),
      line.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 56),
      line.trailingAnchor.constraint(equalTo: trailingAnchor),
      line.topAnchor.constraint(equalTo: topAnchor),
    ])
  }
}
