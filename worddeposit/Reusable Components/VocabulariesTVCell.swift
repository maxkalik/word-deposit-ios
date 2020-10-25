import UIKit

class VocabulariesTVCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var wordsAmountActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var wordsAmountLabel: UILabel!
//    @IBOutlet weak var selectionSwitch: UISwitch!
    @IBOutlet weak var checkbox: Checkbox!
    @IBOutlet weak var containerView: ShadowView!
    
    // MARK: - Istances
    
    var isSelectedVocabulary: Bool! {
        didSet {
            checkbox.isOn = isSelectedVocabulary
            if isSelectedVocabulary {
                containerView.layer.borderWidth = 2
                containerView.layer.borderColor = Colors.orange.cgColor
                containerView.layer.backgroundColor = UIColor.white.cgColor
                titleLabel.textColor = Colors.orange
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
        checkbox.isOn = false
        titleLabel.textColor = Colors.dark
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont(name: Fonts.bold, size: 22)
        titleLabel.addCharactersSpacing(spacing: -0.6, text: titleLabel.text!)
        languageLabel.font = UIFont(name: Fonts.medium, size: 18)
        languageLabel.addCharactersSpacing(spacing: -0.5, text: languageLabel.text!)
        wordsAmountLabel.font = UIFont(name: Fonts.medium, size: 18)
    }
    
    // MARK: - Own Methods
    
    private func setupWordsAmount() {
        UserService.shared.getAmountOfWordsFrom(vocabulary: vocabulary) { count in
            guard let amount = count, self.vocabulary.wordsAmount != amount else { return }
            self.wordsAmount = amount
        }
    }
    
    func configureCell(vocabulary: Vocabulary) {
        self.vocabulary = vocabulary
        
        setupWordsAmount()
        
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 0
        containerView.layer.backgroundColor = UIColor.white.cgColor
    }
}
