import UIKit
import Firebase
import FirebaseFirestore

protocol VocabularyDetailsVCDelegate: VocabulariesTVC {
    func vocabularyDidCreate(_ vocabulary: Vocabulary)
}

class VocabularyDetailsVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var stackViewCenterY: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var languageTextField: UITextField!
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var progressHUD = ProgressHUD(title: "Saving")
    var vocabulary: Vocabulary?
    var isFirstSelected = true
    
    var db: Firestore!
    var userRef: DocumentReference!
    
    private var isKeyboardShowing = false
    private var keyboardHeight: CGFloat!
    
    weak var delegate: VocabularyDetailsVCDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        
        // Primary setting up UI
        setupUI()

        // all observers here because it is the last item in the array of controller
        // Keyboard observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // TextField observers
        titleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        languageTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        disableAllButtons()
        
        if vocabulary != nil {
            titleTextField.borderStyle = .none
            languageTextField.borderStyle = .none
            buttonsStackView.alpha = 0
        } else {
            cancelButton.setTitle("Clear", for: .normal)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        titleTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        languageTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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
        
        // saveButton.layer.opacity = 1
        buttonsStackView.alpha = 1
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if !isKeyboardShowing { return }
        isKeyboardShowing = false
        
        UIView.animate(withDuration: 0.3) {
            self.stackViewCenterY.constant += self.keyboardHeight - self.stackView.frame.size.height
            self.view.layoutIfNeeded()
        }
        
        if vocabulary != nil {
            // saveButton.layer.opacity = 0
            buttonsStackView.alpha = 0
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let title = titleTextField.text, let language = languageTextField.text else { return }

        // if vocabulary is creating new
        guard let vocabulary = self.vocabulary else {
            if title.isNotEmpty && language.isNotEmpty {
                enableAllButtons()
            }
            return
        }
       
        // if vocabulary is editing
        if title != vocabulary.title || language != vocabulary.language {
            enableAllButtons()
            if title.isEmpty || language.isEmpty {
                saveButton.isEnabled = false
                cancelButton.isEnabled = true
            }
        } else {
           disableAllButtons()
       }
    }
    
    // MARK: - Methods
    
    private func setupUI() {
        hideKeyboardWhenTappedAround()
        
        // spinner
        view.addSubview(progressHUD)
        progressHUD.hide()
        titleTextField?.autocorrectionType = .no
        languageTextField?.autocorrectionType = .no
        
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
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        guard let vocabulary = self.vocabulary else {
            titleTextField.text = ""
            languageTextField.text = ""
            disableAllButtons()
            return
        }
        
        titleTextField.text = vocabulary.title
        languageTextField.text = vocabulary.language
        disableAllButtons()
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        progressHUD.show()
        guard let title = titleTextField.text, title.isNotEmpty, let language = languageTextField.text, language.isNotEmpty else {
            simpleAlert(title: "Error", msg: "Fill all fields")
            progressHUD.hide()
            return
        }
        
        guard let user = Auth.auth().currentUser else { return }
        userRef = db.collection("users").document(user.uid)
        
        if vocabulary == nil {
//            let vocabularyRef = userRef.collection("vocabularies").document()
            self.vocabulary = Vocabulary.init(id: "", title: title, language: language, wordsAmount: 0, isSelected: isFirstSelected, timestamp: Timestamp())
//             vocabulary!.id = vocabularyRef.documentID
            // setVocabulary(vocabulary!)
            UserService.shared.setVocabulary(vocabulary!) {
                // complition
                // delegation with updating table view from user service global data [Vocabulary]
                self.progressHUD.hide()
                self.delegate?.vocabularyDidCreate(self.vocabulary!)
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            guard var vocabulary = self.vocabulary else { return }
            vocabulary.title = title
            vocabulary.language = language
            // setVocabulary(existingVocabulary)
            UserService.shared.updateVocabulary(vocabulary) {
                self.progressHUD.hide()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension VocabularyDetailsVC {
    private func enableAllButtons() {
        cancelButton.isEnabled = true
        saveButton.isEnabled = true
    }
    
    private func disableAllButtons() {
        cancelButton.isEnabled = false
        saveButton.isEnabled = false
    }
}
