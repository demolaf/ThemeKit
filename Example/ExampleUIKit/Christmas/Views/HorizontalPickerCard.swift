import UIKit

class HorizontalPickerCard: UIView {
  private var innerScroll: UIScrollView!
  private var hStack: UIStackView!

  init(thumbHeight: CGFloat) {
    super.init(frame: .zero)
    setupCard(thumbHeight: thumbHeight)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  private func setupCard(thumbHeight: CGFloat) {
    backgroundColor = .secondarySystemGroupedBackground
    layer.cornerRadius = 12
    translatesAutoresizingMaskIntoConstraints = false

    innerScroll = UIScrollView()
    innerScroll.showsHorizontalScrollIndicator = false
    innerScroll.translatesAutoresizingMaskIntoConstraints = false

    hStack = UIStackView()
    hStack.axis = .horizontal
    hStack.spacing = 12
    hStack.translatesAutoresizingMaskIntoConstraints = false

    innerScroll.addSubview(hStack)
    addSubview(innerScroll)

    NSLayoutConstraint.activate([
      heightAnchor.constraint(equalToConstant: thumbHeight + 24),

      innerScroll.topAnchor.constraint(equalTo: topAnchor, constant: 12),
      innerScroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
      innerScroll.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      innerScroll.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

      hStack.topAnchor.constraint(equalTo: innerScroll.contentLayoutGuide.topAnchor),
      hStack.bottomAnchor.constraint(equalTo: innerScroll.contentLayoutGuide.bottomAnchor),
      hStack.leadingAnchor.constraint(equalTo: innerScroll.contentLayoutGuide.leadingAnchor),
      hStack.trailingAnchor.constraint(equalTo: innerScroll.contentLayoutGuide.trailingAnchor),
      hStack.heightAnchor.constraint(equalTo: innerScroll.frameLayoutGuide.heightAnchor),
    ])
  }

  func addThumb(_ view: UIView) {
    hStack.addArrangedSubview(view)
  }
}
