import UIKit

extension UITextField {
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        let defaultClearButton = UIButton.appearance(whenContainedInInstancesOf: [UITextField.self])
        defaultClearButton.setBackgroundImage(UIImage(named: Icons.Close), for: .normal)
    }
}
