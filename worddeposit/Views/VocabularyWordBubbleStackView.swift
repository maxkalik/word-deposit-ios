//
//  VocabularyWordBubbleView.swift
//  worddeposit
//
//  Created by Maksim Kalik on 1/21/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit
import Kingfisher

class VocabularyWordBubbleView: UIView {
    
    @IBOutlet weak var wordImageView: UIImageView!
    @IBOutlet weak var wordExampleLabel: VocabularyWordBubbleLabel!
    @IBOutlet weak var wordTranslationLabel: VocabularyWordBubbleLabel!
    @IBOutlet weak var wordDescriptionLabel: VocabularyWordBubbleLabel!
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonSetup()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superview = self.superview {
            frame.size.width = superview.frame.width - 40
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        superview!.setNeedsLayout()
        superview!.layoutIfNeeded()
        
        frame.size.height = stackView.frame.size.height + 40
        center = superview!.center

    }
    
    func commonSetup() {
        alpha = 0
        backgroundColor = Colors.dark.withAlphaComponent(0.97)
        layer.cornerRadius = Radiuses.huge
        layer.masksToBounds = true
        
        wordExampleLabel.fontSize = 22
        // wordExampleLabel.fontColor = Colors.orange
        wordTranslationLabel.fontSize = 18
        wordDescriptionLabel.fontColor = Colors.grey
        wordImageView.layer.cornerRadius = Radiuses.large
        wordImageView.clipsToBounds = true
    }
    
    func configure(with word: Word) {
        setupImage(from: word.imgUrl)
        wordExampleLabel.text = word.example
        wordTranslationLabel.text = word.translation
        
        if word.description.isNotEmpty {
            wordDescriptionLabel.isHidden = false
            wordDescriptionLabel.text = word.description
        } else {
            wordDescriptionLabel.isHidden = true
        }
    }

    func setupImage(from urlStr: String) {
        if let url = URL(string: urlStr) {
            wordImageView.isHidden = false
            wordImageView.kf.indicatorType = .activity
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
            let imgRecourse = ImageResource(downloadURL: url, cacheKey: urlStr)
            wordImageView.kf.setImage(with: imgRecourse, options: options)
        } else {
            wordImageView.isHidden = true
        }
    }
}
