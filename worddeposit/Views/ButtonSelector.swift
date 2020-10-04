import UIKit

class ButtonSelector: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.font = UIFont(name: Fonts.medium, size: 18)
        setTitleColor(Colors.dark, for: .normal)
        guard let text = title(for: .normal) else { return }
        titleLabel?.addCharactersSpacing(spacing: -0.7, text: text)
    }
}
