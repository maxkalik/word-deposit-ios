import UIKit

class PracticeDeskItemButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 12
        clipsToBounds = true
        contentEdgeInsets.top = 10
        contentEdgeInsets.left = 15
        contentEdgeInsets.bottom = 10
        contentEdgeInsets.right = 15
        titleLabel?.font = UIFont(name: "System", size: 15)
    }
}
