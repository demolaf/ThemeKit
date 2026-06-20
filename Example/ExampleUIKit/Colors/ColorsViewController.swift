import ThemeKit
import ThemeKitUIKit
import UIKit

class ColorsViewController: UIViewController {
  private let theme = Theme(suiteName: "com.themekit.example.colors")
  private var applier: ThemeApplier<AppColorsVariant>?

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

  private var swatchesView: SwatchesView!
  private var collectionView: UICollectionView!
  private var followSystemSwitch: UISwitch!

  override func viewDidLoad() {
    super.viewDidLoad()
    initializeViewAppearance()
    setupSwatchesView()
    setupCollectionView()
    setupNavigationBarItems()
    observeTheme()
  }

  // MARK: - Appearance

  private func initializeViewAppearance() {
    title = "Colors"
  }

  // MARK: - Setup

  private func setupSwatchesView() {
    swatchesView = SwatchesView()
    view.addSubview(swatchesView)
    NSLayoutConstraint.activate([
      swatchesView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      swatchesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      swatchesView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }

  private func setupCollectionView() {
    let layout = UICollectionViewCompositionalLayout { _, environment in
      var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
      config.backgroundColor = .clear
      return NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)
    }
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: "cell")
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(collectionView)
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: swatchesView.bottomAnchor, constant: 16),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  private func setupNavigationBarItems() {
    followSystemSwitch = UISwitch()
    followSystemSwitch.addTarget(self, action: #selector(followSystemChanged(_:)), for: .valueChanged)

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

  // MARK: - Theme observation

  private func observeTheme() {
    withObservationTracking {
      let colors = theme.colors
      view.backgroundColor = colors.background
      view.tintColor = colors.tint
      navigationController?.navigationBar.tintColor = colors.tint
      swatchesView.configure(
        tint: colors.tint, background: colors.background, container: colors.container)
      followSystemSwitch.isOn = theme.followsSystem
      collectionView.reloadData()
    } onChange: { [weak self] in
      Task { @MainActor [weak self] in
        self?.observeTheme()
      }
    }
  }

  @objc private func followSystemChanged(_ sender: UISwitch) {
    theme.followsSystem = sender.isOn
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
