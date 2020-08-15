import UIKit

class MessageView: UIView {

    let nibName = "MessageView"
    let height: CGFloat = 300.0
    
    var contentView: UIView!
    var action: (() -> Void)?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: RoundedButton!
    
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
        button.contentEdgeInsets.left = 20
        button.contentEdgeInsets.right = 20
        self.addSubview(view)
        contentView = view
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupOnSuperView()
    }
    
    func setTitles(messageTxt: String, buttonTitle: String) {
        label.text  = messageTxt
        button.setTitle(buttonTitle, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped() {
        print("on button tap")
    }

    func setupOnSuperView() {
        if let superview = self.superview {
            self.center = superview.center
            
            self.frame = CGRect(x: 0,
                                y: 0,
                                width: superview.frame.width,
                                height: UIScreen.main.bounds.height / 2 - 40)
            contentView.frame = self.bounds
        }
    }
    
    func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    func onButtonTap(action: @escaping () -> Void) {
        self.action = action
    }
    
    @IBAction func buttonTap(_ sender: UIButton) {
        action?()
    }
    
    func hide() {
        self.isHidden = true
    }
    
    func show() {
        self.isHidden = false
    }
}
