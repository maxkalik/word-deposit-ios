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
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupOnSuperView()
    }
    
    private func setupTitle() {
        if title != nil {
            let activityIndicatorSize = activityIndictor.frame.size.width
            activityIndictor.frame = CGRect(x: (width - activityIndicatorSize) / 2,
                                            y: 26,
                                            width: activityIndicatorSize,
                                            height: activityIndicatorSize)
            
            layer.cornerRadius = 8.0
            layer.masksToBounds = true
            label.text = title
            label.textAlignment = NSTextAlignment.center
            label.frame = CGRect(x: 10,
                                 y: 26,
                                 width: width - 20,
                                 height: height)
            label.textColor = UIColor.white
            label.font = UIFont.boldSystemFont(ofSize: 14)
        } else {
            activityIndictor.center = contentView.center
        }
    }
    
    private func setupOnSuperView() {
        if let superview = self.superview {
            superview.isUserInteractionEnabled = false
           
            self.frame = CGRect(x: 0,
                                y: 0,
                                width: width,
                                height: height)
            self.center = superview.center
            vibrancyView.frame = self.bounds
            
            activityIndictor.color = .white
            setupTitle()
        }
    }
    
    func show() {
        self.isHidden = false
    }
    
    func success() {
        print("show success")
    }
    
    func setTitle(title: String) {
        self.title = title
        print(title)
        setupTitle()
    }
    
    func hide() {
        if let superview = self.superview {
            superview.isUserInteractionEnabled = true
        }
        self.isHidden = true
    }
}
