//
//  PracticesViewController.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/13/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

class PracticesViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIPopoverPresentationControllerDelegate {
    
    var viewModel: PracticesViewModel?
    private var rightBarItem = TopBarItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        setupUI()
        setupCollectionView()
        setupNavigationBar()
        viewModel?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.viewDidAppear()
    }
    
    private func showTabBar() {
        guard let tabBarController = tabBarController else { return }
        if tabBarController.tabBar.isHidden {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                tabBarController.tabBar.alpha = 0
                tabBarController.tabBar.isHidden = false
                self.navigationController?.setup(isClear: true)
                UIView.animate(withDuration: 0.3) {
                    tabBarController.tabBar.alpha = 1
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    private func registerCell() {
        let nib = UINib(nibName: XIBs.PracticeCVCell, bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: XIBs.PracticeCVCell)
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: ReusableIdentifiers.MessageView)
    }
    
    private func setupUI() {
        collectionView.backgroundView?.backgroundColor = Colors.silver
        collectionView.backgroundColor = Colors.silver

    }
    
    private func setupCollectionView() {
        if let flowlayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowlayout.minimumLineSpacing = 20
        }
        collectionView!.isPrefetchingEnabled = false
    }
    
    private func setupNavigationBar() {
        rightBarItem.setIcon(name: Icons.Profile)
        rightBarItem.circled()
        rightBarItem.onPress {
            self.performSegue(withIdentifier: Segues.Profile, sender: self)
        }
        let rightBarButtonItem = UIBarButtonItem(customView: rightBarItem)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.trainers.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: XIBs.PracticeCVCell, for: indexPath) as? PracticeCVCell {
            guard let trainer = viewModel?.trainers[indexPath.row] else { return PracticeCVCell() }
            cell.backgroundColor = trainer.backgroundColor
            cell.configureCell(cover: trainer.coverImageSource, title: trainer.title)
            return cell
        }
        
        return PracticeCVCell()
    }
}
