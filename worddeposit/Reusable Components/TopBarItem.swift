import UIKit

class TopBarItem: UIView {
    
    var iconName: String?
    var imageView: UIImageView!
    var action: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func setIcon(name: String) {
        iconName = name
    }
    
//    override func didMoveToSuperview() {
//        super.didMoveToSuperview()
//        setupOnSuperView()
//    }
    
    override func layoutSubviews() {
        print("layout subviews")
        setupOnSuperView()
    }
    
    private func commonInit() {
        frame = CGRect(x: 0, y: 0, width: 38, height: 38)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
    }
    
    func circled() {
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
        layer.backgroundColor = Colors.lightGrey.cgColor
        layer.cornerRadius = 19
    }
    
    private func setupOnSuperView() {
        guard let icon = iconName else { return }
        
        imageView.center = center
        
        if let image = UIImage(named: icon) {
            let tintedImage = image.withRenderingMode(.alwaysTemplate)
            imageView.image = tintedImage
            imageView.tintColor = Colors.lightDark
        }
        
        addSubview(imageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(opTap))
        addGestureRecognizer(tap)
    }
    
    @objc func opTap() {
        action?()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.alpha = 0.3
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 1
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 1
    }
    
    func onPress(action: @escaping () -> Void) {
        self.action = action
    }
}
