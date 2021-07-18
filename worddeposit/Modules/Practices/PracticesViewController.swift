//
//  PracticesViewController.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/13/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

class PracticesViewController: BaseViewController {
    
    var viewModel: PracticesViewModel?
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override init() {
        super.init()
        tabBarItem = UITabBarItem(title: "Practices", image: UIImage(named: "icon_practice"), tag: 0)
        title = "Practices"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        viewModel?.delegate = self
        
//        setupNavigationBar()
//        self.title = "Practices"
        registerCell()
        setupCollectionView()
        setupCollectionViewFlowLayout()

        super.viewDidLoad()
        viewModel?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.viewDidAppear()
    }
 
    private func registerCell() {
        let nib = UINib(nibName: XIBs.PracticeCVCell, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: XIBs.PracticeCVCell)
    }
}

extension PracticesViewController {
    private func setupCollectionView() {
        collectionView.frame = view.frame
        collectionView.backgroundColor = .clear
        collectionView.isPrefetchingEnabled = false
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)
    }
    
    private func setupCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 200)
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
}

// MARK: - UICollectionViewDelegate

extension PracticesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.practices.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(indexPath.row)
//        print(viewModel?.practices[indexPath.row])
//        viewModel?.toVocabularies()
        viewModel?.toAddWord()
    }
}

// MARK: - UICollectionViewDataSource

extension PracticesViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: XIBs.PracticeCVCell, for: indexPath) as? PracticeCVCell {
            guard let practice = viewModel?.practices[indexPath.row] else { return PracticeCVCell() }
            cell.backgroundColor = practice.backgroundColor
            cell.configureCell(cover: practice.coverImageSource, title: practice.title)
            return cell
        }

        return PracticeCVCell()
    }
}

// MARK: - PracticesViewModelDelegate

extension PracticesViewController: PracticesViewModelDelegate {
    func allowInteractingWithUI(isInteract: Bool) {
        
    }
    
    func showError(_ msg: String) {
        showAlert(title: "Error", msg: msg)
    }
    
    func startLoading() {
        print("start loading")
        activityIndicator.show()
    }
    
    func finishLoading() {
        print("stop loading")
        activityIndicator.hide()
    }
    
    func showDialogMessage() {
        
    }
    
    func hideDialogMessage() {
        
    }
    
    func finishSetupWords() {
        
    }
}
