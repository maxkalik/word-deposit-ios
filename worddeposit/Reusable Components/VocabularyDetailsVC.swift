import UIKit
import Firebase
import FirebaseFirestore

class VocabularyDetailsVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var stackViewCenterY: NSLayoutConstraint!
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
        
        // Keyboard observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // TextField observers
        titleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        languageTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if vocabulary != nil {
            titleTextField.borderStyle = .none
            languageTextField.borderStyle = .none
            saveButton.layer.opacity = 0
        }
        
        saveButton.isEnabled = false
    }
    
    // MARK: - objc Methods
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if isKeyboardShowing { return }
        isKeyboardShowing = true
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = keyboardFrame.cgRectValue.height
                        
            // Using centerY constrains and changing it allow to save the position of the stackview at the center
            // even if we accidently touch (and drag) uiViewController.
            UIView.animate(withDuration: 0.3) {
                self.stackViewCenterY.constant -= self.keyboardHeight - self.stackView.frame.size.height
                self.view.layoutIfNeeded()
            }
        }
        
        saveButton.layer.opacity = 1
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if !isKeyboardShowing { return }
        isKeyboardShowing = false
        
        UIView.animate(withDuration: 0.3) {
            self.stackViewCenterY.constant += self.keyboardHeight - self.stackView.frame.size.height
            self.view.layoutIfNeeded()
        }
        
        if vocabulary != nil {
            saveButton.layer.opacity = 0
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
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
