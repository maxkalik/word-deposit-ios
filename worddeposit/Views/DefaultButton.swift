import UIKit

class DefaultButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.font = UIFont(name: Fonts.medium, size: 14)
        setTitleColor(Colors.blue, for: .normal)
    }
}
