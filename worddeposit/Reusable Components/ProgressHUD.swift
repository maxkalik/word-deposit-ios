import UIKit

class ProgressHUD: UIVisualEffectView {
    
    var title: String? {
        didSet {
            label.text = title
        }
    }
    
    let width: CGFloat = 120.0
    let height: CGFloat = 120.0
    
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
    let label: UILabel = UILabel()
    let blurEffect = UIBlurEffect(style: .dark)
    let vibrancyView: UIVisualEffectView
    
    let successIcon = UIImage(named: "icon_checkmark_large")
    lazy var imageView = UIImageView(image: successIcon)
    
    init(title: String? = nil) {
        self.title = title
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(effect: blurEffect)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.title = ""
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        contentView.addSubview(vibrancyView)
        contentView.addSubview(activityIndictor)
        contentView.addSubview(label)
        contentView.addSubview(imageView)
        imageView.isHidden = true
        activityIndictor.startAnimating()
        activityIndictor.hidesWhenStopped = true
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupOnSuperView()
        
        layer.masksToBounds = true
        layer.cornerRadius = Radiuses.large
        clipsToBounds = true
    }
    
    private func setupTitle() {
        label.text = title
        label.textAlignment = NSTextAlignment.center
        label.frame = CGRect(x: 10,
                             y: 26,
                             width: width - 20,
                             height: height)
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 14)
    }
    
    private func setupActivityIndicator() {
        activityIndictor.color = .white
        if title != nil {
            let activityIndicatorSize = activityIndictor.frame.size.width
            activityIndictor.frame = CGRect(x: (width - activityIndicatorSize) / 2,
                                            y: 26,
                                            width: activityIndicatorSize,
                                            height: activityIndicatorSize)
            setupTitle()
        } else {
            activityIndictor.center = contentView.center
        }
    }
    
    private func setupImage() {
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = Colors.silver
        if title != nil {
            imageView.frame = CGRect(x: (width - 48) / 2, y: 16, width: 48, height: 48)
            setupTitle()
        } else {
            imageView.center = contentView.center
        }
        
    }
    
    private func setupOnSuperView() {
        if let superview = self.superview {
            superview.isUserInteractionEnabled = false
           
            frame = CGRect(x: 0,
                                y: 0,
                                width: width,
                                height: height)
            center = superview.center
            vibrancyView.frame = self.bounds
            
            setupTitle()
            setupActivityIndicator()
            setupImage()
        }
    }
    
    func show() {
        if let superview = self.superview {
            superview.isUserInteractionEnabled = false
        }
        isHidden = false
    }
    
    func success(with title: String) {
        activityIndictor.stopAnimating()
        imageView.isHidden = false
        self.title = title
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hide()
            self.imageView.isHidden = true
            self.activityIndictor.isHidden = false
            self.activityIndictor.startAnimating()
        }
    }
    
    func setTitle(title: String) {
        self.title = title
        setupTitle()
    }
    
    func hide() {
        if let superview = self.superview {
            superview.isUserInteractionEnabled = true
        }
        
        isHidden = true
    }
}
