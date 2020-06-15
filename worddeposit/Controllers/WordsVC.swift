//
//  WordsVC.swift
//  worddeposit
//
//  Created by Maksim Kalik on 6/15/20.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import UIKit

class WordsVC: UIViewController {

    // Outlets
//    @IBOutlet weak var wordsScrollView: UIScrollView!
    @IBOutlet weak var wordsCollectionView: UICollectionView!
    
    // Variables
    var words = [Word]()
    var wordIndexPath: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        wordsScrollView.delegate = self
        
//        let word01 = setupWordCards(word: words[0])
//        let word02 = setupWordCards(word: words[1])
//        let views: [String: UIView] = ["view": view, "word01" : word01.view, "word02" : word02.view]
//        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[word01(==view)]|", options: [], metrics: nil, views: views)
//        let horizontalConstrains = NSLayoutConstraint.constraints(withVisualFormat: "H:|[word01(==view)][word02(==view)]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: views)
//        NSLayoutConstraint.activate(verticalConstraints + horizontalConstrains)
        setupWordsCollectionView()
    }
    
    private func setupWordsCollectionView() {
        wordsCollectionView.delegate = self
        wordsCollectionView.dataSource = self
        
        if let flowLayout = wordsCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 0
        }
        wordsCollectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        wordsCollectionView.scrollIndicatorInsets = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        let nib = UINib(nibName: Identifiers.WordCollectionViewCell, bundle: nil)
        wordsCollectionView.register(nib, forCellWithReuseIdentifier: Identifiers.WordCollectionViewCell)
    }
    
    /*
    private func setupWordCards(word: Word) -> WordVC {
        let viewController = WordVC()
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
//        viewController.word = word
        wordsScrollView.addSubview(viewController.view)
        addChild(viewController)
        return viewController
    }
    */

}


extension WordsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = wordsCollectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.WordCollectionViewCell, for: indexPath) as? WordCollectionViewCell {
            cell.configureCell(word: words[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    
}
