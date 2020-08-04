import UIKit

class VocabulariesTVCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var wordsAmount: UILabel!
    @IBOutlet weak var selectionSwitch: UISwitch!
    @IBOutlet weak var containerView: UIView!
    
    var isSelectedVocabulary: Bool! {
        didSet {
            selectionSwitch.isOn = isSelectedVocabulary
            if isSelectedVocabulary {
                containerView.layer.borderWidth = 2
                containerView.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
            }

        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectionSwitch.isOn = false
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected == true {
            containerView.layer.backgroundColor = CGColor(srgbRed: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1)
        } else {
            if isSelectedVocabulary == true {
                containerView.layer.backgroundColor = .none
            } else {
                containerView.layer.backgroundColor = CGColor(srgbRed: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 0.5)
            }
        }
    }
    
    func configureCell(title: String, language: String, amount: Int) {
        titleLabel.text = title
        languageLabel.text = language
        wordsAmount.text = String(amount)
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 0
        containerView.layer.backgroundColor = CGColor(srgbRed: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 0.5)
        if isSelectedVocabulary == true {
            containerView.layer.backgroundColor = .none
        }
    }
    
}
