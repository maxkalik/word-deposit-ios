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
        activityIndictor.startAnimating()
        activityIndictor.hidesWhenStopped = true
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupOnSuperView()
        layer.cornerRadius = Radiuses.large
        clipsToBounds = true
    }
    
    private func setupTitle() {
        layer.masksToBounds = true
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
        let image = UIImage(named: "icon_checkmark_large")
        let imageView = UIImageView(image: image)
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = Colors.silver
        
        contentView.addSubview(imageView)
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
            activityIndictor.color = .white
            setupTitle()
            
            setupActivityIndicator()
            if activityIndictor.isHidden {
                setupImage()
            }
        }
    }
    
    func show() {
        if let superview = self.superview {
            superview.isUserInteractionEnabled = false
        }
        isHidden = false
    }
    
    func success(with title: String) {
        self.title = title
        activityIndictor.stopAnimating()
        setupImage()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.activityIndictor.startAnimating()
            self.hide()
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
