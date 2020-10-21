import UIKit

class SecondaryButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.font = UIFont(name: Fonts.bold, size: 14)
        guard let text = title(for: .normal) else { return }
        titleLabel?.addCharactersSpacing(spacing: -0.6, text: text)
        layer.cornerRadius = Radiuses.large
        layer.backgroundColor = UIColor.white.cgColor
    }
    
    override var isEnabled: Bool {
        didSet {
            if self.isEnabled {
                setTitleColor(Colors.blue, for: .normal)
            } else {
                setTitleColor(Colors.grey.withAlphaComponent(0.5), for: .normal)
            }
        }
    }
}
