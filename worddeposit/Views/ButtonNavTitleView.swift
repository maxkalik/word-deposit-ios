import UIKit

class ButtonNavTitleView: UIButton {
    
    let icon = UIImage(named: Icons.Arrow)
    let spacing: CGFloat = 8.0 / 2
    var buttonWidth: CGFloat!
    var imageWidth: CGFloat!
    var action: (() -> Void)?

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        setImage(icon, for: .normal)
        tintColor = Colors.dark
        setTitleColor(Colors.dark, for: .normal)
        titleLabel?.font = UIFont(name: Fonts.bold, size: 22)
        semanticContentAttribute = .forceRightToLeft
        layer.cornerRadius = Radiuses.large
        configureEdges()
        
        addTarget(self, action: #selector(touchStart), for: .touchDown)
        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(touchCancel), for: .touchCancel)
    }
    
    @objc func touchStart() {
        // alpha = 0.3
        backgroundColor = Colors.lightGrey
    }
    
    @objc func touchUpInside() {
        imageView?.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        backgroundColor = .none
        action?()
    }
    
    @objc func touchCancel() {
        backgroundColor = .none
    }
    
    func initialState() {
        UIView.animate(withDuration: 0.5) {
            self.imageView?.transform = .identity
        }
    }
    
    func onPress(action: @escaping () -> Void) {
        self.action = action
    }
    
    func configureEdges() {
        buttonWidth = frame.width
        imageWidth = imageView!.frame.width
        
        imageEdgeInsets = UIEdgeInsets(top: 0, left: buttonWidth - imageWidth + spacing, bottom: 0, right: -(buttonWidth-imageWidth) - spacing)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth - spacing, bottom: 0, right: imageWidth + spacing)
        contentEdgeInsets = UIEdgeInsets(top: 4, left: spacing + 14, bottom: 4, right: spacing + 14)
    }
}
