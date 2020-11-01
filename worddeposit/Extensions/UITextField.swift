import UIKit

extension UITextField {
    func applyCustomClearButton() {
        text = ""
        clearButtonMode = .never
        rightViewMode   = .whileEditing

        let clearButton = UIButton(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        clearButton.setImage(UIImage(named: Icons.Close)!, for: .normal)
        clearButton.addTarget(self, action: #selector(clearClicked), for: .touchUpInside)

        rightView = clearButton
    }

    @objc func clearClicked(sender: UIButton) {
        text = ""
    }
}
