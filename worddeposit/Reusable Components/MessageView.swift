import UIKit

class MessageView: UIView {

    let nibName = "MessageView"
    let height: CGFloat = 300.0
    
    var contentView: UIView!
    var action: (() -> Void)?
    var secondaryAction: (() -> Void)?
    

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var primaryButton: PrimaryButton!
    @IBOutlet weak var secondaryButton: DefaultButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        
        primaryButton.contentEdgeInsets.left = 20
        primaryButton.contentEdgeInsets.right = 20
        primaryButton.setTitleColor(UIColor.white, for: .normal)
        
        secondaryButton.isHidden = true
        
        addSubview(view)
        contentView = view
        contentView.layer.backgroundColor = Colors.silver.cgColor
        
        label.font = UIFont(name: Fonts.medium, size: 22)
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupOnSuperView()
    }
    
    func setTitles(messageTxt: String, buttonTitle: String, secondaryButtonTitle: String? = nil) {
        label.text  = messageTxt
        label.addCharactersSpacing(spacing: -0.8, text: messageTxt)
        primaryButton.setTitle(buttonTitle, for: .normal)
        // primaryButton.addTarget(self, action: #selector(secondaryButtonTapped), for: .touchUpInside)
        
        secondaryButton.setTitle(secondaryButtonTitle, for: .normal)
        
    }
    
    /*
    @objc func secondaryButtonTapped() {
        print("on button tap")
    }
    */
    
    func setupOnSuperView() {
        if let superview = self.superview {
            frame = superview.bounds
        }
    }
    
    func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    func onPrimaryButtonTap(action: @escaping () -> Void) {
        self.action = action
    }
    
    func onSecondaryButtonTap(secondaryAction: @escaping () -> Void) {
        self.secondaryAction = secondaryAction
    }
    
    @IBAction func secondaryButtonTap(_ sender: UIButton) {
        secondaryAction?()
    }
    
    
    @IBAction func primaryButtonTap(_ sender: UIButton) {
        action?()
    }
    
    func hide() {
        self.isHidden = true
    }
    
    func show() {
        self.isHidden = false
    }
    
    func showSecondaryButton() {
        secondaryButton.isHidden = false
        secondaryButton.contentEdgeInsets.left = 20
        secondaryButton.contentEdgeInsets.right = 20
    }
}
