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
    @IBOutlet weak var wordsScrollView: UIScrollView!
    
    // Variables
    var words = [Word]()
    var wordIndexPath: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wordsScrollView.delegate = self
        
        let word01 = setupWordCards(word: words[0])
        let word02 = setupWordCards(word: words[1])
        let views: [String: UIView] = ["view": view, "word01" : word01.view, "word02" : word02.view]
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[word01(==view)]|", options: [], metrics: nil, views: views)
        let horizontalConstrains = NSLayoutConstraint.constraints(withVisualFormat: "H:|[word01(==view)][word02(==view)]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: views)
        NSLayoutConstraint.activate(verticalConstraints + horizontalConstrains)
    }
    
    private func setupWordCards(word: Word) -> WordVC {
        let viewController = WordVC()
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
//        viewController.word = word
        wordsScrollView.addSubview(viewController.view)
        addChild(viewController)
        return viewController
    }

}


extension WordsVC: UIScrollViewDelegate {
    
}
