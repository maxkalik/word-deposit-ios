//
//  TextViews.swift
//  worddeposit
//
//  Created by Maksim Kalik on 1/11/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

class PrimaryTextView: UITextView, UITextViewDelegate {
    var limitOfString: Int?
    var isContainer = false
    var textPadding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        delegate = self
        autocorrectionType = .no
        smartInsertDeleteType = .no
        
        textColor = .white
        layer.cornerRadius = Radiuses.large
        layer.backgroundColor = Colors.blue.cgColor
        
        font = UIFont(name: Fonts.bold, size: 22.0)
        
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        let textAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.kern: -0.8,
            NSAttributedString.Key.font: font!,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes(textAttributes, range: NSRange(location: 0, length: text.count))
        attributedText = attributedString
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
    }
    
    // func textViewDidBeginEditing(_ textView: UITextView) {
    //     UIView.animate(withDuration: 0.3) {
    //         self.backgroundColor = Colors.dark.withAlphaComponent(0.1)
    //     }
    // }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // if !isContainer {
            layer.backgroundColor = Colors.blue.cgColor
        // }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let limit = limitOfString else { return true }
        return TextFieldLimit.checkMaxLength(from: self.text, range: range, string: text, limit: limit)
    }
}


