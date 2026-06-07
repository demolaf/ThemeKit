import UIKit
import ThemeKit

class HomeViewController: UIViewController {
    private let theme: Theme

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { _, environment in
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.backgroundColor = .clear
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)
        }
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: "cell")
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

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
        initializeSubviews()
        observeTheme()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyConstraints()
    }

    private func initializeViewAppearance() {
        title = "ThemeKit"
    }

    private func initializeSubviews() {
        view.addSubview(collectionView)
    }

    private func observeTheme() {
        withObservationTracking {
            let tint = UIColor(hex: theme.colors.tintHex)
            view.backgroundColor = UIColor(hex: theme.colors.backgroundHex)
            view.tintColor = tint
            navigationController?.navigationBar.tintColor = tint
            collectionView.reloadData()
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.observeTheme()
            }
        }
    }

    private func applyConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        rows.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = rows[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! UICollectionViewListCell
        var content = UIListContentConfiguration.cell()
        content.image = UIImage(systemName: row.icon)
        content.imageProperties.tintColor = UIColor(hex: theme.colors.tintHex)
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
