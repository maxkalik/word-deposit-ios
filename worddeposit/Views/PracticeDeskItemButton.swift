import UIKit


class PracticeDeskItemLabel: UILabel {
    let padding = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }
}

/*
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
*/
