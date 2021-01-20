//
//  LimitTextField.swift
//  worddeposit
//
//  Created by Maksim Kalik on 9/23/20.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import UIKit.UITextField

class TextFieldLimit {
    static func checkMaxLength(textField: UITextField!, maxLength: Int) {
        if (textField.text!.count > maxLength) {
            textField.deleteBackward()
        }
    }
    
    static func checkMaxLength(_ textField: UITextField, range: NSRange, string: String, limit: Int) -> Bool {
        guard let text = textField.text, let rangeOfTextToReplace = Range(range, in: text) else {
            return false
        }
        let substringToReplace = text[rangeOfTextToReplace]
        let count = text.count - substringToReplace.count + string.count
        return count <= limit
    }
    
    static func checkMaxLength(from text: String, range: NSRange, string: String, limit: Int) -> Bool {
        guard let rangeOfTextToReplace = Range(range, in: text) else { return false }
        let substringToReplace = text[rangeOfTextToReplace]
        let count = text.count - substringToReplace.count + string.count
        return count <= limit
    }
}
