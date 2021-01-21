//
//  VocabularyWordBubbleView.swift
//  worddeposit
//
//  Created by Maksim Kalik on 1/21/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

class VocabularyWordBubbleView: UIView {
    
    @IBOutlet weak var wordImageView: UIImageView!
    @IBOutlet weak var wordExampleLabel: UILabel!
    @IBOutlet weak var wordTranslationLabel: UILabel!
    @IBOutlet weak var wordDescriptionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commonSetup()
        
        wordExampleLabel.font = UIFont(name: Fonts.bold, size: 16)
        wordExampleLabel.lineBreakMode = .byWordWrapping
        wordExampleLabel.numberOfLines = 0
        wordExampleLabel.textColor = .white
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superview = self.superview {
            frame.size.width = superview.frame.width - 40
            center = superview.center
        }
    }
    
    func onPress() {
        UIView.animate(withDuration: 0.3) { [self] in
            alpha = 1
        }
    }
    
    func onFinishPress() {
        UIView.animate(withDuration: 0.3) { [self] in
            alpha = 0
        }
    }
    
    func commonSetup() {
        alpha = 0
        backgroundColor = Colors.dark.withAlphaComponent(0.97)
        layer.cornerRadius = Radiuses.large
        layer.masksToBounds = true
    }
}
