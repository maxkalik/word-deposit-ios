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
        titleLabel.text = ""
        languageLabel.text = ""
        wordsAmountLabel.text = "0"
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
    
    private func updateWordsAmount(vocabulary: Vocabulary, userRef: DocumentReference) {
        let vocabularyRef = userRef.collection("vocabularies").document(vocabulary.id)
        let wordsRef = vocabularyRef.collection("words")
        wordsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                self.wordsAmountActivityIndicator.stopAnimating()
            } else  {
                guard let snap = snapshot else { return }
                if snap.count != self.wordsAmount {
                    self.wordsAmount = snap.count
                    vocabularyRef.updateData(["words_amount" : snap.count]) { (error) in
                        if let error = error {
                            debugPrint(error.localizedDescription)
                        }
                    }
                }
                self.wordsAmountActivityIndicator.stopAnimating()
            }
        }
    }
    
    func configureCell(vocabulary: Vocabulary, userRef: DocumentReference) {
        titleLabel.text = vocabulary.title
        languageLabel.text = vocabulary.language
        wordsAmountLabel.text = String(vocabulary.wordsAmount)
        
        updateWordsAmount(vocabulary: vocabulary, userRef: userRef)
        
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 0
        containerView.layer.backgroundColor = CGColor(srgbRed: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 0.5)
        if isSelectedVocabulary == true {
            containerView.layer.backgroundColor = .none
        }
    }
}
