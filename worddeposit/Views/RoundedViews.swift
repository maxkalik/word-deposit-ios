import UIKit
import Foundation

class RoundedView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 8
        layer.isOpaque = false
//        layer.backgroundColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.5)
    }
}
