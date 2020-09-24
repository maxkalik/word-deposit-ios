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

class LoginTextField: UITextField {
    
    var bottomBorder = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Prepare for uiview
        translatesAutoresizingMaskIntoConstraints = false
        bottomBorder = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        bottomBorder.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
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
        font = UIFont(name: "Futura", size: 16.0)
    }
}
