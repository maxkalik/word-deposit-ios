//
//  WordCollectionViewCell.swift
//  worddeposit
//
//  Created by Maksim Kalik on 6/16/20.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import UIKit

class WordCollectionViewCell: UICollectionViewCell {

    
//    @IBOutlet weak var wordExampleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(word: Word) {
//        wordExampleLabel.text = word.example
        print(word)
    }

}
