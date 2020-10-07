import UIKit

protocol SuccessMessageVCDelegate: AnyObject {
    func onSuccessMessageButtonTap()
}

class SuccessMessageVC: UIViewController {

    @IBOutlet weak var contentView: RoundedView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var button: PrimaryButton!
    
    var titleTxt: String!
    var descriptionTxt: String!
    var titleBtn: String = "Finish"
    
    weak var delegate: SuccessMessageVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layer.backgroundColor = Colors.yellow.cgColor
        
        titleLabel.font = UIFont(name: Fonts.bold, size: 28)
        titleLabel.addCharactersSpacing(spacing: -0.8, text: titleTxt)
        
        descriptionLabel.font = UIFont(name: Fonts.medium, size: 18)
        descriptionLabel.addCharactersSpacing(spacing: -0.6, text: descriptionTxt)
        
        titleLabel.text = titleTxt
        descriptionLabel.text = descriptionTxt
        button.setTitle(titleBtn, for: .normal)
    }
        
    @IBAction func buttonTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        delegate?.onSuccessMessageButtonTap()
    }
}
