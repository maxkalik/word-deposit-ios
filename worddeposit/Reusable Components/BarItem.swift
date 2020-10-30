import UIKit

class TopBarItem: UIView {
    
    var iconName: String? {
        didSet {
            print(iconName ?? "")
        }
    }

    
    init(frame: CGRect, iconName: String) {
        self.iconName = iconName
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        frame = CGRect(x: 0, y: 0, width: 38, height: 38)
        layer.backgroundColor = Colors.lightGrey.cgColor
        layer.cornerRadius = 19
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
        imageView.center = center
        
        if let image = UIImage(named: Icons.Profile) {
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
