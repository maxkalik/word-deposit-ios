//
//  WordTextView.swift
//  worddeposit
//
//  Created by Maksim Kalik on 1/19/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

protocol WordTextViewDelegate: AnyObject {
    func editingChanged()
}

class WordTextView: UITextView, UITextViewDelegate {
    
    weak var actionsDelegate: WordTextViewDelegate?
    
    public var limitOfString: Int?
    public var placeholder: String?
    public var placeholderColor: UIColor?
    public var activeTextColor: UIColor?
    public var backgroundColorOnShow: UIColor?
    public var backgroundColorOnFocus: UIColor?
    
    var isPlaceholderSet = false
    
    override var text: String! {
        didSet {
            if text.isEmpty && !isPlaceholderSet {
                setupPlaceholder()
            } else {
                textColor = activeTextColor
            }
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        common()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        common()
    }
    
    func setupStyle(fontSize: CGFloat, letterSpacing: Double, activeTextColor: UIColor, backgroundColor: UIColor, isInitialBackground: Bool? = nil) {
        font = UIFont(name: Fonts.bold, size: fontSize)
        tintColor = activeTextColor
        self.backgroundColorOnShow = backgroundColor
        if isInitialBackground != nil {
            self.backgroundColor = backgroundColor
        }
        
        self.activeTextColor = activeTextColor
      
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        let textAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: activeTextColor,
            .kern: letterSpacing,
            .font: font!,
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes(textAttributes, range: NSRange(location: 0, length: text.count))
        attributedText = attributedString
    }
    
    func setupShadow(with color: UIColor) {
        clipsToBounds = false
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 0
        layer.shadowColor = color.cgColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
    }
    
    private func common() {
        autocorrectionType = .no
        smartInsertDeleteType = .no
        textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layer.cornerRadius = Radiuses.large
    }
    
    private func setupPlaceholder() {
        text = placeholder
        textColor = placeholderColor ?? Colors.lightGrey
        isPlaceholderSet = true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textColor == placeholderColor { textView.text = "" }
        UIView.animate(withDuration: 0.3) { [self] in
            backgroundColor = backgroundColorOnFocus
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty { setupPlaceholder() }
        UIView.animate(withDuration: 0.3) { [self] in
            backgroundColor = backgroundColorOnShow
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        actionsDelegate?.editingChanged()
        let fixedWidth = frame.size.width
        let newSize = sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let limit = limitOfString else { return true }
        return TextFieldLimit.checkMaxLength(from: self.text, range: range, string: text, limit: limit)
    }
}
