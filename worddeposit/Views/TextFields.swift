import UIKit
import Foundation

class BaseTextField: UITextField {
    override func layoutSubviews() {
        super.layoutSubviews()
        // weird but we need to clear background
        for view in subviews {
            if let button = view as? UIButton {
                button.setImage(button.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
                button.tintColor = .clear
            }
        }
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var originalRect = super.clearButtonRect(forBounds: bounds)
        originalRect.size.width = 16
        originalRect.size.height = 16
        return originalRect.offsetBy(dx: 10, dy: 0)
    }
}

class CellTextField: BaseTextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 0
        layer.backgroundColor = .none
        font = UIFont(name: "System", size: 17.0)
        clearButtonMode = .whileEditing
        // applyCustomClearButton()
    }
}


class PrimaryTextField: UITextField, UITextFieldDelegate {
    
    var limitOfString: Int?
    var isContainer = false
    var textPadding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override func awakeFromNib() {
        super.awakeFromNib()
            
        delegate = self
        autocorrectionType = .no
        smartInsertDeleteType = UITextSmartInsertDeleteType.no
        
        layer.cornerRadius = Radiuses.large
        
        // Remove Default Border
        borderStyle = .none
        
        layer.backgroundColor = isContainer ? Colors.blue.cgColor : UIColor.clear.cgColor
        
        // Placeholder
        attributedPlaceholder = NSAttributedString(
            string: self.placeholder != nil ? self.placeholder! : "",
            attributes: [
                NSAttributedString.Key.foregroundColor: Colors.dark.withAlphaComponent(0.2),
                NSAttributedString.Key.kern: -0.4
            ]
        )
        
        // Font
        font = UIFont(name: Fonts.bold, size: 22.0)
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        defaultTextAttributes = [
            NSAttributedString.Key.foregroundColor: isContainer ? UIColor.white : Colors.dark,
            NSAttributedString.Key.kern: -0.8,
            NSAttributedString.Key.font: font!,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !isContainer {
            UIView.animate(withDuration: 0.3) {
                    self.backgroundColor = Colors.dark.withAlphaComponent(0.1)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if !isContainer {
            UIView.animate(withDuration: 0.3) {
                self.backgroundColor = .clear
            }            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let limit = limitOfString else { return true }
        return TextFieldLimit.checkMaxLength(textField, range: range, string: string, limit: limit)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = self.text else { return }
        if text.isEmpty {
            UIView.animate(withDuration: 0.3) {
                self.backgroundColor = .clear
            }
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}

class SecondaryTextField: UITextField, UITextFieldDelegate {
    
    var limitOfString: Int?
    var symbolAtTheEnd: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
            
        delegate = self
        autocorrectionType = .no
        smartInsertDeleteType = UITextSmartInsertDeleteType.no
        
        layer.cornerRadius = Radiuses.large
        
        // Remove Default Border
        borderStyle = .none
        
        // Placeholder
        attributedPlaceholder = NSAttributedString(
            string: self.placeholder != nil ? self.placeholder! : "",
            attributes: [
                NSAttributedString.Key.foregroundColor: Colors.dark.withAlphaComponent(0.2),
                NSAttributedString.Key.kern: -0.4
            ]
        )
        
        // Font
        font = UIFont(name: Fonts.medium, size: 18.0)
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        defaultTextAttributes = [
            NSAttributedString.Key.foregroundColor: Colors.dark,
            NSAttributedString.Key.kern: -0.6,
            NSAttributedString.Key.font: font!,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = Colors.dark.withAlphaComponent(0.1)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = .clear
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let limit = limitOfString else { return true }
        return TextFieldLimit.checkMaxLength(textField, range: range, string: string, limit: limit)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = self.text else { return }
        if text.isEmpty {
            UIView.animate(withDuration: 0.3) {
                self.backgroundColor = .clear
            }
        }
    }
}

