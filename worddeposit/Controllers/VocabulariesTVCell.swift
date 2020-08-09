import UIKit
import FirebaseAuth
import FirebaseFirestore

class VocabulariesTVCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var wordsAmountLabel: UILabel!
    @IBOutlet weak var selectionSwitch: UISwitch!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Istances
    
    var wordsAmount: Int! {
        didSet {
            wordsAmountLabel.text = String(wordsAmount)
        }
    }
    var isSelectedVocabulary: Bool! {
        didSet {
            selectionSwitch.isOn = isSelectedVocabulary
            if isSelectedVocabulary {
                containerView.layer.borderWidth = 2
                containerView.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
            }

        }
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectionSwitch.isOn = false
        wordsAmountLabel.text = "0"
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
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
    
    func configureCell(vocabulary: Vocabulary, userRef: DocumentReference) {
        titleLabel.text = vocabulary.title
        languageLabel.text = vocabulary.language
        
        let ref = userRef.collection("vocabularies").document(vocabulary.id).collection("words")
        ref.getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else  {
                guard let snap = snapshot else { return }
                self.wordsAmount = snap.count
            }
        }
        
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 0
        containerView.layer.backgroundColor = CGColor(srgbRed: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 0.5)
        if isSelectedVocabulary == true {
            containerView.layer.backgroundColor = .none
        }
    }
}
