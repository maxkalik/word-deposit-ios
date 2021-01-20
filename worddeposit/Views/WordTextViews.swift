//
//  TextViews.swift
//  worddeposit
//
//  Created by Maksim Kalik on 1/11/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

class PrimaryTextView: WordTextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        placeholder = "Example"
        limitOfString = Limits.wordExample
        backgroundColorOnFocus = Colors.blue
        placeholderColor = UIColor.white.withAlphaComponent(0.5)
        setupStyle(fontSize: 22, letterSpacing: -0.8, activeTextColor: .white, backgroundColor: Colors.blue, isInitialBackground: true)
        setupShadow(with: Colors.darkBlue)
    }
}

class TranslationTextView: WordTextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        placeholder = "Translation"
        limitOfString = Limits.wordTranslation
        backgroundColorOnFocus = Colors.dark.withAlphaComponent(0.1)
        placeholderColor = Colors.lightGrey
        setupStyle(fontSize: 22, letterSpacing: -0.8, activeTextColor: Colors.dark, backgroundColor: .clear)
    }
}

class DescriptionTextView: WordTextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        placeholder = "Description"
        limitOfString = Limits.wordDescription
        backgroundColorOnFocus = Colors.dark.withAlphaComponent(0.1)
        placeholderColor = Colors.lightGrey
        setupStyle(fontSize: 18, letterSpacing: -0.6, activeTextColor: Colors.darkGrey, backgroundColor: .clear)
    }
    
    func show() {
        alpha = 1
        isHidden = false
    }
    
    func hide() {
        alpha = 0
        isHidden = true
    }
}
