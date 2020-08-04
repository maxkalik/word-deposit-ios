import UIKit

class VocabulariesTVCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var wordsAmount: UILabel!
    @IBOutlet weak var selectionSwitch: UISwitch!
    
    var isSelectedVocabulary: Bool! {
        didSet {
            selectionSwitch.isOn = isSelectedVocabulary
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectionSwitch.isOn = false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(title: String, language: String, amount: Int) {
        titleLabel.text = title
        languageLabel.text = language
        wordsAmount.text = String(amount)
    }
    
}
