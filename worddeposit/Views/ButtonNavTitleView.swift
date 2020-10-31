import UIKit

class ButtonNavTitleView: UIButton {
    
    let icon = UIImage(named: Icons.Arrow)

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        setImage(icon, for: .normal)
        tintColor = Colors.dark
        setTitleColor(Colors.dark, for: .normal)
        titleLabel?.font = UIFont(name: Fonts.bold, size: 22)
        semanticContentAttribute = .forceRightToLeft
        layer.cornerRadius = Radiuses.large
        
        configureEndges()
    }
    
    func configureEndges() {
        let buttonWidth = frame.width
        let imageWidth = imageView!.frame.width
        let spacing: CGFloat = 8.0 / 2
        
        imageEdgeInsets = UIEdgeInsets(top: 0, left: buttonWidth - imageWidth + spacing, bottom: 0, right: -(buttonWidth-imageWidth) - spacing)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth - spacing, bottom: 0, right: imageWidth + spacing)
        contentEdgeInsets = UIEdgeInsets(top: 4, left: spacing + 14, bottom: 4, right: spacing + 14)
    }
}
