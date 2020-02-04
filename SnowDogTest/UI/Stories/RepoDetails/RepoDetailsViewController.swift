//
//  RepoDetailsViewController.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import UIKit
import SafariServices

internal final class RepoDetailsViewController: CoordinatableViewController {

    enum SectionKind {
        case description(String, String?)
        case button(String)
    }
    
    // MARK: - Private properties
    
    private var _sections = [SectionKind]()
    private var _repo: Repo?
    
    private lazy var _collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        return layout
    }()
    
    private lazy var _collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: _collectionLayout)
        collectionView.delaysContentTouches = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = .init(top: 80, left: 16, bottom: 0, right: 16)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(nibCellClass: DescriptionCell.self)
        collectionView.register(nibCellClass: ButtonCell.self)
        
        return collectionView
    }()
    
    // MARK: - View lifecycle
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupUI()
    }
    
    // MARK: - Internal methods
    
    internal func configure(with repo: Repo) {
        _repo = repo
        
        var languageString: String
        if let language = repo.language {
            languageString = language
        } else {
            languageString = "Undefined language"
        }
        _sections = [
            .description("id: #\(repo.id)", nil),
            .description(languageString, nil),
            .description(String(repo.stars), "ico_star"),
            .description(String(repo.watchers), "ico_watch"),
            .description(String(repo.forks ?? 0), "ico_fork"),
            .button("Open on Github")
        ]
        
        navigationItem.title = repo.name
        
        _collectionView.performBatchUpdates(nil)
    }

    // MARK: - Private methods
    
    private func setupCollectionView() {
        _collectionView.delegate = self
        _collectionView.dataSource = self
    }
    
    private func setupUI() {
        [_collectionView].forEach(view.addSubview)
        view.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            _collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            _collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            _collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            _collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension RepoDetailsViewController: UICollectionViewDataSource {
    
    // MARK: - UICollectionViewDataSource methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return _sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch _sections[indexPath.section] {
        case let .description(text, imageName):
            let cell: DescriptionCell = collectionView.dequeue(for: indexPath)
            cell.configure(text: text, imageName: imageName)
            return cell
        case let .button(text):
            let cell: ButtonCell = collectionView.dequeue(for: indexPath)
            cell.configure(with: text)
            return cell
        }
    }
}

extension RepoDetailsViewController: UICollectionViewDelegate {
    
    // MARK: - UICollectionViewDelegate methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        switch _sections[indexPath.section] {
        case .description:
            ()
        case .button:
            let safari = SFSafariViewController(url: URL(string: _repo!.url)!)
            safari.preferredBarTintColor = .white
            safari.preferredControlTintColor = .black
            
            let vc = UIViewController()
            vc.addChild(safari)
            vc.view.addSubview(safari.view)
            
            safari.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                safari.view.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
                safari.view.leftAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.leftAnchor),
                safari.view.rightAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.rightAnchor),
                safari.view.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor),
            ])
            present(vc, animated: true)
        }
    }
}

extension RepoDetailsViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDelegateFlowLayout methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)
        
        switch _sections[indexPath.section] {
        case .description:
            return .init(width: availableWidth, height: 20)
        case .button:
            return .init(width: availableWidth, height: 50)
        }
    }
}
