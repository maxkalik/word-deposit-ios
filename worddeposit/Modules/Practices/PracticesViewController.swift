//
//  PracticesViewController.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/13/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

class PracticesViewController: UIViewController {
    
    var viewModel: PracticesViewModel?
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var rightBarItem = TopBarItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        setupNavigationBar()
        viewModel?.viewDidLoad()
//        self.title = "Practices"
        registerCell()
        setupCollectionView()
        setupCollectionViewFlowLayout()
        
//        activityIndicator.hide()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.viewDidAppear()

    }
    
//    private func showTabBar() {
//        guard let tabBarController = tabBarController else { return }
//        if tabBarController.tabBar.isHidden {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
//                guard let self = self else { return }
//                tabBarController.tabBar.alpha = 0
//                tabBarController.tabBar.isHidden = false
//                self.navigationController?.setup(isClear: true)
//                UIView.animate(withDuration: 0.3) {
//                    tabBarController.tabBar.alpha = 1
//                    self.view.layoutIfNeeded()
//                }
//            }
//        }
//    }
    
//    private func setupNavigationBar() {
//        rightBarItem.setIcon(name: Icons.Profile)
//        rightBarItem.circled()
//        rightBarItem.onPress {
//            self.performSegue(withIdentifier: Segues.Profile, sender: self)
//        }
//        let rightBarButtonItem = UIBarButtonItem(customView: rightBarItem)
//        self.navigationItem.rightBarButtonItem = rightBarButtonItem
//    }
    
    private func registerCell() {
        let nib = UINib(nibName: XIBs.PracticeCVCell, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: XIBs.PracticeCVCell)
    }
}

extension PracticesViewController {
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
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

extension PracticesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.practices.count ?? 0
    }
}

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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
//        print(viewModel?.practices[indexPath.row])
    }
}

extension PracticesViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let screenSize = UIScreen.main.bounds
//        return CGSize(width: screenSize.width - 40, height: 170)
//    }
}
