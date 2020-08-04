import UIKit
import Firebase
import FirebaseFirestore

class VocabularyDetailsVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var languageTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var progressHUD = ProgressHUD(title: "Saving")
    var vocabulary: Vocabulary?
    
    var db: Firestore!
    var vocabularyRef: DocumentReference!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        setupUI()
    }
    
    // MARK: - Methods
    
    private func setupUI() {
        view.addSubview(progressHUD)
        progressHUD.hide()
        titleTextField.autocorrectionType = .no
        languageTextField.autocorrectionType = .no
//        saveButton.isEnabled = false
        
        guard let title = vocabulary?.title, let language = vocabulary?.language else { return }
        if title.isNotEmpty && language.isNotEmpty {
            titleTextField.text = title
            languageTextField.text = language
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func savePressed(_ sender: UIButton) {
        progressHUD.show()
        guard let title = titleTextField.text, title.isNotEmpty, let language = languageTextField.text, language.isNotEmpty else {
            simpleAlert(title: "Error", msg: "Fill all fields")
            progressHUD.hide()
            return
        }
        
        guard let user = Auth.auth().currentUser else { return }
        vocabularyRef = db.collection("users").document(user.uid).collection("vocabularies").document()
        

        if vocabulary == nil {
            vocabulary = Vocabulary.init(id: "", title: title, language: language, words: [], isSelected: true, timestamp: Timestamp())
            vocabulary!.id = vocabularyRef.documentID
        }
        
        let data = Vocabulary.modelToData(vocabulary: vocabulary!)
        vocabularyRef.setData(data, merge: true) { (error) in
            if let error = error {
                self.simpleAlert(title: "Error", msg: error.localizedDescription)
                self.progressHUD.hide()
            }
            // success
            self.progressHUD.hide()
            self.dismiss(animated: true, completion: nil)
            print("success")
        }
    }
}
