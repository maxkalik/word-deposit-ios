//
//  VocabularyWordBubbleLabel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 1/21/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

class VocabularyWordBubbleLabel: UILabel {
    
    var fontSize: CGFloat? {
        didSet {
            font = UIFont(name: Fonts.bold, size: fontSize ?? 16)
        }
    }
    var fontColor: UIColor? {
        didSet {
            textColor = fontColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonSetup()
    }
    
    func commonSetup() {
        lineBreakMode = .byWordWrapping
        numberOfLines = 0
        textColor = .white
    }
}
