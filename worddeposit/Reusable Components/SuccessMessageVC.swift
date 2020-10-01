import UIKit

protocol SuccessMessageVCDelegate: AnyObject {
    func onSuccessMessageButtonTap()
}

class SuccessMessageVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var titleTxt: String!
    var descriptionTxt: String!
    var titleBtn: String = "Finish"
    
    weak var delegate: SuccessMessageVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleTxt
        descriptionLabel.text = descriptionTxt
        button.setTitle(titleBtn, for: .normal)
    }
        
    @IBAction func buttonTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        delegate?.onSuccessMessageButtonTap()
    }
}
