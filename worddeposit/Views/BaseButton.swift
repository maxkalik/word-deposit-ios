import UIKit

class BaseButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.font = UIFont(name: Fonts.medium, size: 16)
    }
    
    override var isEnabled: Bool {
        didSet {
            if self.isEnabled {
                setTitleColor(Colors.blue, for: .normal)
            } else {
                setTitleColor(Colors.grey, for: .normal)
            }
        }
    }
}
