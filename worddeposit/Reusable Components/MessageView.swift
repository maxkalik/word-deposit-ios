import UIKit

@IBDesignable
class MessageView: UIView {

    let nibName = "MessageView"
    let width: CGFloat = 320.0
    let height: CGFloat = 200.0
    
    var contentView: UIView!
    var action: (() -> Void)?
    
    @IBOutlet weak var titleLabel: UILabel!
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
        self.addSubview(view)
        contentView = view
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupOnSuperView()
    }
    
    func setTitle(title: String) {
        titleLabel.text  = title
    }

    func setupOnSuperView() {
        self.frame = CGRect(x: (UIScreen.main.bounds.width / 2) - (width / 2),
                            y: (UIScreen.main.bounds.height / 2) - height,
                            width: width,
                            height: height)
        contentView.frame = self.bounds
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
}
