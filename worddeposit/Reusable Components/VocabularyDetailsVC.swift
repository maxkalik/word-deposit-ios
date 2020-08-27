import UIKit
import Firebase
import FirebaseFirestore

class VocabularyDetailsVC: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var languageTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var progressHUD = ProgressHUD(title: "Saving")
    var vocabulary: Vocabulary?
    var isFirstSelected = true
    
    var db: Firestore!
    var userRef: DocumentReference!
    
    private var isKeyboardShowing = false
    private var keyboardHeight: CGFloat!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        setupUI()
        
        hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - objc Methods
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if isKeyboardShowing { return }
        isKeyboardShowing = true
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = keyboardFrame.cgRectValue.height
            stackView.frame.origin.y -= keyboardHeight - stackView.frame.size.height
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if !isKeyboardShowing { return }
        isKeyboardShowing = false
        
        stackView.frame.origin.y += keyboardHeight - stackView.frame.size.height
        
    }
    
    // MARK: - Methods
    
    private func setupUI() {
        view.addSubview(progressHUD)
        progressHUD.hide()
        titleTextField?.autocorrectionType = .no
        languageTextField?.autocorrectionType = .no
//        saveButton.isEnabled = false
        
        guard let title = vocabulary?.title, let language = vocabulary?.language else { return }
        if title.isNotEmpty && language.isNotEmpty {
            titleTextField.text = title
            languageTextField.text = language
        }
    }
    
    private func setVocabulary(_ vocabulary: Vocabulary) {
        let ref = userRef.collection("vocabularies").document(vocabulary.id)
        let data = Vocabulary.modelToData(vocabulary: vocabulary)
        ref.setData(data, merge: true) { (error) in
            if let error = error {
                self.simpleAlert(title: "Error", msg: error.localizedDescription)
                self.progressHUD.hide()
            }
            // success
            self.progressHUD.hide()
            self.navigationController?.popViewController(animated: true)
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
        userRef = db.collection("users").document(user.uid)
        
        if vocabulary == nil {
            let vocabularyRef = userRef.collection("vocabularies").document()
            vocabulary = Vocabulary.init(id: "", title: title, language: language, wordsAmount: 0, isSelected: isFirstSelected, timestamp: Timestamp())
            vocabulary!.id = vocabularyRef.documentID
            setVocabulary(vocabulary!)
        } else {
            guard var existingVocabulary = vocabulary else { return }
            existingVocabulary.title = title
            existingVocabulary.language = language
            setVocabulary(existingVocabulary)
        }
    }
}
