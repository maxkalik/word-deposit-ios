import UIKit

class Spinner: UIActivityIndicatorView {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.backgroundColor = CGColor(srgbRed: 25, green: 10, blue: 255, alpha: 1.0)
    }
}
