import UIKit

class LoginTitle: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        textColor = Colors.dark
        font = UIFont(name: Fonts.medium, size: 22)
    }
}
