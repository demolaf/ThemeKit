import ThemeKit
import UIKit

class ColorsViewController: UIViewController {
  private let theme: Theme

  private let items: [(icon: String, name: String)] = [
    ("paintbrush", "Theming"),
    ("star.fill", "Featured"),
    ("bookmark.fill", "Saved"),
    ("bell.fill", "Notifications"),
    ("gearshape.fill", "Settings"),
    ("person.fill", "Profile"),
    ("creditcard.fill", "Billing"),
    ("chart.bar.fill", "Analytics"),
  ]

  private let tintSwatchColor: UIView = {
    let v = UIView()
    v.layer.cornerRadius = 12
    v.layer.borderWidth = 0.5
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }()

  private let backgroundSwatchColor: UIView = {
    let v = UIView()
    v.layer.cornerRadius = 12
    v.layer.borderWidth = 0.5
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }()

  private let containerSwatchColor: UIView = {
    let v = UIView()
    v.layer.cornerRadius = 12
    v.layer.borderWidth = 0.5
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }()

  private lazy var swatchesView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.distribution = .fillEqually
    stack.spacing = 12
    stack.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    stack.isLayoutMarginsRelativeArrangement = true
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.addArrangedSubview(makeSwatchItem(colorView: tintSwatchColor, label: "Tint"))
    stack.addArrangedSubview(makeSwatchItem(colorView: backgroundSwatchColor, label: "Background"))
    stack.addArrangedSubview(makeSwatchItem(colorView: containerSwatchColor, label: "Container"))
    return stack
  }()

  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewCompositionalLayout { _, environment in
      var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
      config.backgroundColor = .clear
      return NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)
    }
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.dataSource = self
    cv.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: "cell")
    cv.translatesAutoresizingMaskIntoConstraints = false
    return cv
  }()

  private lazy var followSystemSwitch: UISwitch = {
    let s = UISwitch()
    s.addTarget(self, action: #selector(followSystemChanged(_:)), for: .valueChanged)
    return s
  }()

  init(theme: Theme) {
    self.theme = theme
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func viewDidLoad() {
    super.viewDidLoad()
    initializeViewAppearance()
    initializeSubviews()
    setupNavigationBarItems()
    observeTheme()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    applyConstraints()
  }

  private func initializeViewAppearance() {
    title = "Colors"
  }

  private func initializeSubviews() {
    view.addSubview(swatchesView)
    view.addSubview(collectionView)
  }

  private func setupNavigationBarItems() {
    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(
        image: UIImage(systemName: "paintbrush.pointed"),
        primaryAction: UIAction { [weak self] _ in
          guard let self else { return }
          let pickerVC = ColorsPickerViewController(theme: theme)
          present(pickerVC, animated: true)
        }
      ),
      UIBarButtonItem(customView: followSystemSwitch),
    ]
  }

  private func observeTheme() {
    withObservationTracking {
      let colors = theme.colors
      view.backgroundColor = colors.background
      view.tintColor = colors.tint
      navigationController?.navigationBar.tintColor = colors.tint
      tintSwatchColor.backgroundColor = colors.tint
      backgroundSwatchColor.backgroundColor = colors.background
      containerSwatchColor.backgroundColor = colors.container
      let separatorColor = UIColor.separator.cgColor
      tintSwatchColor.layer.borderColor = separatorColor
      backgroundSwatchColor.layer.borderColor = separatorColor
      containerSwatchColor.layer.borderColor = separatorColor
      followSystemSwitch.isOn = theme.followsSystem
      collectionView.reloadData()
    } onChange: { [weak self] in
      Task { @MainActor [weak self] in
        self?.observeTheme()
      }
    }
  }

  private func applyConstraints() {
    NSLayoutConstraint.activate([
      swatchesView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      swatchesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      swatchesView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

      collectionView.topAnchor.constraint(equalTo: swatchesView.bottomAnchor, constant: 16),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  @objc private func followSystemChanged(_ sender: UISwitch) {
    theme.followsSystem = sender.isOn
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
}

extension ColorsViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
    -> Int
  {
    items.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell
  {
    let item = items[indexPath.row]
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    var content = UIListContentConfiguration.cell()
    content.image = UIImage(systemName: item.icon)
    content.imageProperties.tintColor = theme.colors.tint
    content.text = item.name
    cell.backgroundConfiguration?.backgroundColor = .tertiarySystemFill
    cell.contentConfiguration = content
    return cell
  }
}
