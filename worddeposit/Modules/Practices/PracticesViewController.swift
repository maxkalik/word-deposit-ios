//
//  PracticesViewController.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/13/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

final class PracticesViewController: BaseViewController {
    
    var viewModel: PracticesViewModel?
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        viewModel?.delegate = self
        viewModel?.viewDidLoad()
        
        registerCell()
        setupCollectionView()
        setupCollectionViewFlowLayout()
        setupTabBarItem()
        title = viewModel?.title

        super.viewDidLoad()
    }
    
    deinit {
        print("deinit \(self)")
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
    private func setupTabBarItem() {
        guard let viewModel = self.viewModel else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tabBarItem = UITabBarItem(
                title: viewModel.title,
                image: UIImage(named: viewModel.tabBarIcon.rawValue),
                tag: 0
            )
        }
    }
    
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
        showAlert(title: "==== ERROR", msg: msg)
    }
    
    func startLoading() {
        activityIndicator.show()
    }
    
    func finishLoading() {
        activityIndicator.hide()
    }
    
    func showDialogMessage(with title: String, buttonTitle: String) {
        showMessageView(title: title, buttonTitle: buttonTitle)
    }
    
    func hideDialogMessage() {
        hideMessage()
    }
    
    func finishSetupWords() {
        
    }
}
