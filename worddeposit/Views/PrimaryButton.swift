import UIKit
import Foundation

class PrimaryButton: UIButton {
    
    var titleColor: UIColor?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = Radiuses.large
        titleLabel?.font = UIFont(name: Fonts.medium, size: 16 )
        layer.backgroundColor = Colors.dark.cgColor
        contentEdgeInsets.left = 20
        contentEdgeInsets.right = 20
        
        if titleColor == nil {
            setTitleColor(.white, for: .normal)
        } else {
            setTitleColor(titleColor, for: .normal)
        }
        
        if self.isEnabled {
            layer.backgroundColor = Colors.dark.cgColor
        } else {
            layer.backgroundColor = Colors.dark.withAlphaComponent(0.4).cgColor
        }
    }
}
