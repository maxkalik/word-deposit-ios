import UIKit

class WordDeskItemButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 12
        titleEdgeInsets.top = 5
        titleEdgeInsets.left = 10
        titleEdgeInsets.bottom = 5
        titleEdgeInsets.right = 5
    }
}
