//
//  ReposViewController.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import UIKit

internal final class ReposViewController: UIViewController {
    
    // MARK: - Internal properties
    
    internal var showDetails: ((Repo) -> ())!
    
    // MARK: - Private properties
    
    private var _repoService: RepoService?
    private var _objects: [Repo] = []
    private var _filteredObjects: [Repo] {
        if let filterText = _searchController.searchBar.text, !filterText.isEmpty {
            return _objects
                .filter {
                    $0.name.lowercased().contains(filterText.lowercased())
                        || ($0.language ?? "").lowercased().contains(filterText.lowercased())
                        || String($0.id).lowercased().contains(filterText.lowercased())
                }
        } else {
            return _objects
        }
    }
    private var isInlineView = true
    
    private let _refreshControl = UIRefreshControl()
    
    private lazy var _collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        return layout
    }()
    
    private lazy var _collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: _collectionLayout)
        collectionView.delaysContentTouches = false
        collectionView.refreshControl = _refreshControl
        collectionView.refreshControl?.layer.zPosition = -1
        collectionView.backgroundColor = .white
        collectionView.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(nibCellClass: RepoCell.self)
        return collectionView
    }()
    
    private let _keyboardOffsetView = KeyboardOffsetView()
    
    private let _searchController = UISearchController(searchResultsController: nil)
    
    private var _rightBarButtonItem: UIBarButtonItem!
    
    // MARK: - View lifecycle
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupCollectionView()
        setupSearchController()
    }
    
    // MARK: - Internal methods
    
    internal func configure(with repoService: RepoService) {
        _repoService = repoService
        refreshRepo(fromNetwork: true)
        _repoService?.contextWasChanged = { [weak self] in
            self?.refreshRepo(fromNetwork: false)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(recognizedTapGesture))
        tapGesture.cancelsTouchesInView = false
        view.gestureRecognizers?.forEach(view.removeGestureRecognizer)
        [tapGesture].forEach(view.addGestureRecognizer)
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        let rightBarButtonItemCustomView = UIButton()
        rightBarButtonItemCustomView.setImage(UIImage(named: "ico_inline")?.withRenderingMode(.alwaysTemplate), for: .normal)
        rightBarButtonItemCustomView.addTarget(self, action: #selector(tappedRightBarButtonItem), for: .touchUpInside)
        rightBarButtonItemCustomView.imageEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        rightBarButtonItemCustomView.tintColor = UIColor.black.withAlphaComponent(0.7)
        
        _rightBarButtonItem = .init(customView: rightBarButtonItemCustomView)
        _refreshControl.addTarget(self, action: #selector(refreshControlValueWasChanged), for: .valueChanged)
        
        navigationItem.title = "My repos"
        navigationItem.backBarButtonItem = .init(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem!.tintColor = UIColor.black.withAlphaComponent(0.7)
        navigationItem.rightBarButtonItem = _rightBarButtonItem
        navigationItem.searchController = _searchController
        view.backgroundColor = .white
        
        [_collectionView, _keyboardOffsetView].forEach(view.addSubview)
        
        _keyboardOffsetView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            _collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            _collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            _collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            _collectionView.bottomAnchor.constraint(equalTo: _keyboardOffsetView.topAnchor),

            _keyboardOffsetView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            _keyboardOffsetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            _keyboardOffsetView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            
            rightBarButtonItemCustomView.heightAnchor.constraint(equalToConstant: 44),
            rightBarButtonItemCustomView.widthAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupCollectionView() {
        _collectionView.dataSource = self
        _collectionView.delegate = self
    }
    
    private func setupSearchController() {
        _searchController.obscuresBackgroundDuringPresentation = false
        _searchController.searchResultsUpdater = self
        _searchController.searchBar.tintColor = UIColor.black.withAlphaComponent(0.7)
    }
    
    private func refreshRepo(fromNetwork: Bool) {
        if fromNetwork {
            _repoService?.refreshRepoPage()
        }
        _collectionView.performBatchUpdates({
            _objects = _repoService?.repoPage?.repos ?? []
        })
    }
    
    @objc private func refreshControlValueWasChanged() {
        _refreshControl.endRefreshing()
        refreshRepo(fromNetwork: true)
    }
    
    @objc private func tappedRightBarButtonItem() {
        if _collectionView.indexPathsForVisibleItems.contains(.init(item: 0, section: 0)) {
            _collectionView.performBatchUpdates({
                isInlineView = !isInlineView
            })
        } else {
            isInlineView = !isInlineView
            _collectionView.collectionViewLayout.invalidateLayout()
        }
        
        let button = self._rightBarButtonItem.customView as! UIButton
        UIView.transition(with: button, duration: 0.3, options: .transitionFlipFromRight, animations: {
            button.setImage(UIImage(named: self.isInlineView ? "ico_inline" : "ico_grid"), for: .normal)
        })
    }
    
    @objc private func recognizedTapGesture() {
        view.endEditing(true)
        _searchController.isActive = false
    }
    
    private func setEmptyLabel(with message: String?) {
        if let message = message {
            let label = UILabel()
            label.text = message
            label.textColor = UIColor.black.withAlphaComponent(0.7)
            label.textAlignment = .center
            label.numberOfLines = 0
            
            _collectionView.backgroundView = label
        } else {
            _collectionView.backgroundView = nil
        }
    }
}

extension ReposViewController: UICollectionViewDataSource {
    
    // MARK: - UICollectionViewDataSource methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = _searchController.isActive ? _filteredObjects.count : _objects.count
        setEmptyLabel(with: count == 0 ? "No results matched your search" : nil)
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: RepoCell = collectionView.dequeue(for: indexPath)
        let object = _searchController.isActive ? _filteredObjects[indexPath.item] : _objects[indexPath.item]
        cell.configure(with: object, languageColor: _repoService?.hexForLanguage(object.language))
        return cell
    }
}

extension ReposViewController: UICollectionViewDelegate {
    
    // MARK: - UICollectionViewDelegate methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard _objects.indices.contains(indexPath.item) else { return }

        showDetails(_objects[indexPath.item])
    }
}

extension ReposViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDelegateFlowLayout methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { fatalError() }
        
        let avaliableWidth = collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)
        let width = isInlineView ? avaliableWidth : (avaliableWidth - layout.minimumInteritemSpacing) / 2
        let height: CGFloat = isInlineView ? 83 : width
        return .init(width: width, height: height)
    }
}

extension ReposViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        _collectionView.performBatchUpdates(nil)
    }
}
