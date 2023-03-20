/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A collection view controller that displays chart visualizations for health data.
*/

import UIKit
import HealthKit

struct TrackingData {
    let startDate : Date
    let endDate : Date
    let value : Double
}

/// A base view controller with a collection view displaying data type data and their chart visualizations using `DataTypeCollectionViewCell`.
class RangeBasedViewController: UIViewController {
    
    static let cellIdentifier = "RangeTypeDataViewCell"
    
    var segmentItems : [String] = []
    
    var rangeTitle = createChartDateRangeLabel()
    
    var rangeVariant: DateRangeVariant = .DAILY(7)
    
    // MARK: - Properties
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.register(RangeTypeDataViewCell.self, forCellWithReuseIdentifier: Self.cellIdentifier)
        collectionView.alwaysBounceVertical = true
        
        return collectionView
    }()
    
    lazy var segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: segmentItems)
        
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        
        return segmentControl
    }()
    
    var data: [(dataTypeIdentifier: String, values: [TrackingData])] = []
    
    // MARK: - Initalizers
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        setUpViews()
        
        title = tabBarItem.title
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        collectionView.setCollectionViewLayout(makeLayout(), animated: true)
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    // MARK: - View Helper Functions
    
    private func setupNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setUpViews() {
        view.addSubview(collectionView)
        view.addSubview(segmentControl)
        setUpConstraints()
    }
    
    private func setUpConstraints() {
        var constraints: [NSLayoutConstraint] = []
        
        constraints += createSegmentControlConstraints()
        constraints += createCollectionViewConstraints()
        NSLayoutConstraint.activate(constraints)
    }
    
    private func createCollectionViewConstraints() -> [NSLayoutConstraint] {
        return [
            collectionView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ]
    }
    
    private func createSegmentControlConstraints() -> [NSLayoutConstraint] {
        return [
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentControl.heightAnchor.constraint(equalToConstant: 40),
            segmentControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            segmentControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ]
    }

    private func makeLayout() -> UICollectionViewLayout {
        let verticalMargin: CGFloat = 8
        let horizontalMargin: CGFloat = 20
        let interGroupSpacing: CGFloat = horizontalMargin
        
        let cellHeight = calculateCellHeight(horizontalMargin: horizontalMargin,
                                             verticalMargin: verticalMargin)

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(cellHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(cellHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = interGroupSpacing
        section.contentInsets = .init(top: verticalMargin, leading: horizontalMargin,
                                      bottom: verticalMargin, trailing: horizontalMargin)

        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    /// Return a collection view cell height that is equivalent to the smaller dimension of the view's bounds minus margins on each side.
    private func calculateCellHeight(horizontalMargin: CGFloat, verticalMargin: CGFloat) -> CGFloat {
        let isLandscape = UIApplication.shared.isLandscape
        let widthInset = (horizontalMargin * 2) + view.safeAreaInsets.left + view.safeAreaInsets.right
        var heightInset = (verticalMargin * 2) // safeAreaInsets already accounted for in tabBar bounds.
        
        heightInset += navigationController?.navigationBar.bounds.height ?? 0
        heightInset += tabBarController?.tabBar.bounds.height ?? 0
        
        let cellHeight = isLandscape ? view.bounds.height - heightInset : view.bounds.width - widthInset
        
        return cellHeight
    }
}

extension RangeBasedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let content = data[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.cellIdentifier,
                                                            for: indexPath) as? RangeTypeDataViewCell else {
            return RangeTypeDataViewCell()
        }
        
        cell.updateChartView(with: content.dataTypeIdentifier, values: content.values, title: rangeTitle, variant: rangeVariant)
        
        return cell
    }
}
