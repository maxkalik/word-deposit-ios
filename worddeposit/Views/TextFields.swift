import UIKit
import Foundation

class CellTextField: UITextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 0
        layer.backgroundColor = .none
        font = UIFont(name: "System", size: 17.0)
        clearButtonMode = .whileEditing
    }
}

class LoginTextField: UITextField, UITextFieldDelegate {
    
    var bottomBorder = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        delegate = self
        autocorrectionType = .no
        
        // Prepare for uiview
        translatesAutoresizingMaskIntoConstraints = false
        bottomBorder = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        bottomBorder.backgroundColor = Colors.dark.withAlphaComponent(0.4)
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomBorder)
        
        // Remove Default Border
        borderStyle = .none
        
        // Setup Anchors
        bottomBorder.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomBorder.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bottomBorder.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bottomBorder.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Font
        font = UIFont(name: Fonts.medium, size: 16.0)
        textColor = Colors.dark
        
        // Placeholder
        attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes: [NSAttributedString.Key.foregroundColor: Colors.dark.withAlphaComponent(0.4)])
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        bottomBorder.backgroundColor = Colors.dark
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = self.text else { return }
        if text.isEmpty {
            bottomBorder.backgroundColor = Colors.dark.withAlphaComponent(0.4)
        }
    }
    
}
