import UIKit
import FirebaseAuth
import FirebaseFirestore
import Kingfisher

protocol WordCollectionViewCellDelegate: class {
    func showAlert(title: String, message: String)
}

class WordCollectionViewCell: UICollectionViewCell {

    // Outlets
    @IBOutlet weak var wordImageButton: UIButton!
    @IBOutlet weak var wordExampleTextField: UITextField!
    @IBOutlet weak var wordTranslationTextField: UITextField!
    @IBOutlet weak var saveChangingButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var loader: RoundedView!
    
    // Variables
    var word: Word!
    var db = Firestore.firestore()
    
    weak var delegate: WordCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loader.isHidden = true
    }
    
    
    func configureCell(word: Word, delegate: WordCollectionViewCellDelegate) {
        
        self.word = word
        self.delegate = delegate
        
        self.word = word
        if let url = URL(string: word.imgUrl) {
            wordImageButton.imageView?.kf.indicatorType = .activity
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
            wordImageButton.kf.setImage(with: url, for: .normal, options: options)
        }
        wordExampleTextField.text = word.example
        wordTranslationTextField.text = word.translation
    }
    
    @IBAction func wordImageButtonTouched(_ sender: UIButton) {
        print(word.imgUrl)
    }

    @IBAction func onSaveChangingTouched(_ sender: UIButton) {
        self.loader.isHidden = false
        guard let example = wordExampleTextField.text, example.isNotEmpty,
            let translation = wordTranslationTextField.text, translation.isNotEmpty
            else {
//                simpleAlert(title: "Error", msg: "Fields cannot be empty")
                return
        }
        
        // TODO: shoud be rewrited in the singleton
        guard let user = Auth.auth().currentUser else { return }
        let wordRef = db.collection("users").document(user.uid).collection("words").document(word.id)
        
        // Making a copy of the word
        var updatedWord = word!
        updatedWord.example = example
        updatedWord.translation = translation
        let data = Word.modelToData(word: updatedWord)

        wordRef.updateData(data) { error in
            if let error = error {
                self.delegate?.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                self.delegate?.showAlert(title: "Success", message: "Word has been updated")
            }
            self.word = updatedWord
            self.loader.isHidden = true
//            self.navigationController?.popViewController(animated: true)
//            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func onCancelTouched(_ sender: UIButton) {
        self.delegate?.showAlert(title: "Cancel Pressed", message: "Word has been updated")
    }
}
