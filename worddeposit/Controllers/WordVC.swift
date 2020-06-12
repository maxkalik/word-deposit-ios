import UIKit
import FirebaseAuth
import FirebaseFirestore
import Kingfisher

class WordVC: UIViewController {

    // Outlets
    @IBOutlet weak var wordImageBtn: RoundedButton!
    @IBOutlet weak var exampleTextField: UITextField!
    @IBOutlet weak var translationTextField: UITextField!
    @IBOutlet weak var saveChangingBtn: RoundedButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var loader: RoundedView!
    
    
    // Variables
    var word: Word!
    var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWord()
        
    }
    
    private func setupWord() {
        
        if let url = URL(string: word.imgUrl) {
            wordImageBtn.imageView?.kf.indicatorType = .activity
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
            wordImageBtn.kf.setImage(with: url, for: .normal, options: options)
        }
        exampleTextField.text = word.example
        translationTextField.text = word.translation
    }
    
    private func setupUI() {
        loader.isHidden = true
        wordImageBtn.layer.cornerRadius = 8
    }
    
    @IBAction func wordImageBtnTapped(_ sender: Any) {
        
    }
    
    @IBAction func saveChangingBtnTapped(_ sender: Any) {
        self.loader.isHidden = false
        guard let example = exampleTextField.text, example.isNotEmpty,
            let translation = translationTextField.text, translation.isNotEmpty
            else {
                simpleAlert(title: "Error", msg: "Fields cannot be empty")
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
                self.simpleAlert(title: "Error", msg: error.localizedDescription)
            } else {
                self.simpleAlert(title: "Success", msg: "Word has been updated")
            }
            self.word = updatedWord
            self.loader.isHidden = true
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }

    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        setupWord()
    }
    
}
