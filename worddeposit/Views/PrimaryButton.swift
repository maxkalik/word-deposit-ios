import UIKit
import Foundation

class PrimaryButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 12
        setTitleColor(Colors.yellow, for: .normal)
        layer.backgroundColor = Colors.dark.cgColor
    }
    
    override var isEnabled: Bool {
        didSet {
            if self.isEnabled {
                layer.backgroundColor = Colors.dark.cgColor
            } else {
                layer.backgroundColor = Colors.grey.cgColor
            }
        }
    }
}
