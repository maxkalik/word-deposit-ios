import UIKit

extension UITextField {
    func applyCustomClearButton() {
        clearButtonMode = .never
        rightViewMode   = .whileEditing

        let clearButton = UIButton(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        clearButton.setImage(UIImage(named: "icon_close")!, for: .normal)
        clearButton.addTarget(self, action: #selector(clearClicked), for: .touchUpInside)

        rightView = clearButton
    }

    @objc func clearClicked(sender: UIButton) {
        text = ""
    }
}
