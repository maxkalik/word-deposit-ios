//
//  TextViews.swift
//  worddeposit
//
//  Created by Maksim Kalik on 1/11/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

class PrimaryTextView: UITextView, UITextViewDelegate {
    var limitOfString: Int? // protocol
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        delegate = self
        autocorrectionType = .no
        smartInsertDeleteType = .no
        
        textColor = .white
        tintColor = .white
        
        clipsToBounds = false
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 0
        layer.shadowColor = Colors.darkBlue.cgColor
        
        layer.cornerRadius = Radiuses.large
        backgroundColor = Colors.blue
        
        font = UIFont(name: Fonts.bold, size: 22.0)
        
        textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
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
    
    // dinamic size of view
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
    }

    
    func textViewDidEndEditing(_ textView: UITextView) {
        backgroundColor = Colors.blue
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let limit = limitOfString else { return true }
        return TextFieldLimit.checkMaxLength(from: self.text, range: range, string: text, limit: limit)
    }
}






class TranslationTextView: UITextView, UITextViewDelegate {
    var limitOfString: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        delegate = self
        autocorrectionType = .no
        smartInsertDeleteType = .no
        
        textColor = Colors.dark
        layer.cornerRadius = Radiuses.large
        backgroundColor = .clear
        
        font = UIFont(name: Fonts.bold, size: 22.0)
        
        textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        let textAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Colors.dark,
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
 
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = Colors.dark.withAlphaComponent(0.1)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = .clear
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let limit = limitOfString else { return true }
        return TextFieldLimit.checkMaxLength(from: self.text, range: range, string: text, limit: limit)
    }
}




class DescriptionTextView: UITextView, UITextViewDelegate {
    var limitOfString: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        delegate = self
        autocorrectionType = .no
        smartInsertDeleteType = .no
        
        textColor = Colors.darkGrey
        tintColor = Colors.darkGrey
        
        layer.cornerRadius = Radiuses.large
        backgroundColor = .clear
        
        font = UIFont(name: Fonts.bold, size: 18.0)
        
        textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        let textAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Colors.darkGrey,
            NSAttributedString.Key.kern: -0.6,
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
 
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = Colors.dark.withAlphaComponent(0.1)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = .clear
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let limit = limitOfString else { return true }
        return TextFieldLimit.checkMaxLength(from: self.text, range: range, string: text, limit: limit)
    }
}
