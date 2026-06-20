import ThemeKit
import UIKit

class HomeViewController: UIViewController {
  private let theme: Theme

  private var collectionView: UICollectionView!

  private let rows: [(title: String, icon: String)] = [
    ("Colors", "paintbrush.fill"),
    ("Christmas", "snowflake"),
  ]

  init(theme: Theme) {
    self.theme = theme
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func viewDidLoad() {
    super.viewDidLoad()
    initializeViewAppearance()
    setupCollectionView()
    observeTheme()
  }

  // MARK: - Appearance

  private func initializeViewAppearance() {
    title = "ThemeKit"
  }

  // MARK: - Setup

  private func setupCollectionView() {
    let layout = UICollectionViewCompositionalLayout { _, environment in
      var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
      config.backgroundColor = .clear
      return NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)
    }
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: "cell")
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(collectionView)
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }

  // MARK: - Theme observation

  private func observeTheme() {
    withObservationTracking {
      view.backgroundColor = theme.colors.background
      view.tintColor = theme.colors.tint
      navigationController?.navigationBar.tintColor = theme.colors.tint
      collectionView.reloadData()
    } onChange: { [weak self] in
      Task { @MainActor [weak self] in
        self?.observeTheme()
      }
    }
  }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
    -> Int
  {
    rows.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell
  {
    let row = rows[indexPath.row]
    let cell =
      collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      as! UICollectionViewListCell
    var content = UIListContentConfiguration.cell()
    content.image = UIImage(systemName: row.icon)
    content.imageProperties.tintColor = theme.colors.tint
    content.text = row.title
    cell.accessories = [.disclosureIndicator()]
    cell.backgroundConfiguration?.backgroundColor = .secondarySystemGroupedBackground
    cell.contentConfiguration = content
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)
    switch indexPath.row {
    case 0:
      navigationController?.pushViewController(ColorsViewController(theme: theme), animated: true)
    case 1:
      navigationController?.pushViewController(ChristmasViewController(), animated: true)
    default:
      break
    }
  }
}
