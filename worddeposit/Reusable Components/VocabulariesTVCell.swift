import UIKit
import FirebaseAuth
import FirebaseFirestore

class VocabulariesTVCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var wordsAmountActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var wordsAmountLabel: UILabel!
    @IBOutlet weak var selectionSwitch: UISwitch!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Istances
    
    var isSelectedVocabulary: Bool! {
        didSet {
            selectionSwitch.isOn = isSelectedVocabulary
            if isSelectedVocabulary {
                containerView.layer.borderWidth = 2
                containerView.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
            }
        }
    }
    
    var vocabulary: Vocabulary! {
        didSet {
            titleLabel.text = vocabulary.title
            languageLabel.text = vocabulary.language
            wordsAmountLabel.text = String(vocabulary.wordsAmount)
        }
    }
    
    var wordsAmount: Int! {
        didSet {
            wordsAmountActivityIndicator.stopAnimating()
            wordsAmountLabel.isHidden = false
            wordsAmountLabel.text = String(wordsAmount)
        }
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectionSwitch.isOn = false
    }
    
    // MARK: - Own Methods
    
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
    
    private func setupWordsAmount() {
        UserService.shared.getAmountOfWordsFrom(vocabulary: vocabulary) { count in
            if self.vocabulary.wordsAmount != count {
                self.wordsAmount = count
            }
        }
    }
    
    func configureCell(vocabulary: Vocabulary) {
        self.vocabulary = vocabulary
        
        setupWordsAmount()
        
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 0
        containerView.layer.backgroundColor = CGColor(srgbRed: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 0.5)
        if isSelectedVocabulary == true {
            containerView.layer.backgroundColor = .none
        }
    }
}
