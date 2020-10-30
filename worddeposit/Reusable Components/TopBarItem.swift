import UIKit

class TopBarItem: UIView {
    
    var iconName: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func setIcon(name: String) {
        print(name)
        iconName = name
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupOnSuperView()
    }
    
    private func commonInit() {
        frame = CGRect(x: 0, y: 0, width: 38, height: 38)
        layer.backgroundColor = Colors.lightGrey.cgColor
        layer.cornerRadius = 19
    }
    
    private func setupOnSuperView() {
        guard let icon = iconName else { return }
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
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
        print("tapped")
    }
}
