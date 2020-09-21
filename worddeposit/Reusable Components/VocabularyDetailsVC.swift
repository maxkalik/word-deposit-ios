import UIKit
import FirebaseFirestore

protocol VocabularyDetailsVCDelegate: AnyObject {
    func vocabularyDidCreate(_ vocabulary: Vocabulary)
    func vocabularyDidUpdate(_ vocabulary: Vocabulary, index: Int)
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
    
    private var isKeyboardShowing = false
    private var keyboardHeight: CGFloat!
    
    weak var delegate: VocabularyDetailsVCDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Primary setting up UI
        setupUI()

        // all observers here because it is the last item in the array of controller
        // Keyboard observers
        let nc = NotificationCenter.default
        
        nc.addObserver(self, selector: #selector(currentVocabularyDidUpdate), name: NSNotification.Name(rawValue: Keys.currentVocabularyDidUpdateKey), object: nil)
        
        nc.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // TextField observers
        titleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        languageTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func currentVocabularyDidUpdate() {
        print("notification has been sent - currentVocabularyDidUpdate")
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
        
        buttonsStackView.alpha = 1
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if !isKeyboardShowing { return }
        isKeyboardShowing = false
        
        UIView.animate(withDuration: 0.3) {
            self.stackViewCenterY.constant += self.keyboardHeight - self.stackView.frame.size.height
            self.view.layoutIfNeeded()
        }
        
        if vocabulary != nil { buttonsStackView.alpha = 0 }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let title = titleTextField.text, let language = languageTextField.text else { return }

        // if vocabulary is creating new
        guard let vocabulary = self.vocabulary else {
            if title.isNotEmpty && language.isNotEmpty {
                enableAllButtons()
            } else {
                disableAllButtons()
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
    
    private func completeSaving(vocabulary: Vocabulary, index: Int? = nil) {
        self.progressHUD.hide()
        self.navigationController?.popViewController(animated: true)
        guard let index = index else {
            /// create new
            self.delegate?.vocabularyDidCreate(self.vocabulary!)
            return
        }
        /// update with index
        self.delegate?.vocabularyDidUpdate(vocabulary, index: index)
        if vocabulary.isSelected {
            // update vocabulary title in vocabulary tvc
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(rawValue: Keys.currentVocabularyDidUpdateKey), object: self)
            }
        }
    }
    
    private func onCancel() {
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
    
    // MARK: - IBActions
    
    @IBAction func cancelTapped(_ sender: UIButton) { onCancel() }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        progressHUD.show()
        guard let title = titleTextField.text, title.isNotEmpty, let language = languageTextField.text, language.isNotEmpty else {
            simpleAlert(title: "Error", msg: "Fill all fields")
            progressHUD.hide()
            return
        }
        
        // validation
        if UserService.shared.vocabularies.contains(where: { $0.title == title }) {
            simpleAlert(title: "Vocabulary is already exist", msg: "You have already the same vocabulary title. Make different one.") { _ in
                self.titleTextField.becomeFirstResponder()
            }
            progressHUD.hide()
            onCancel()
            return
        }
        
        if vocabulary == nil {
            
            self.vocabulary = Vocabulary.init(
                id: "",
                title: title,
                language: language,
                wordsAmount: 0,
                isSelected: isFirstSelected,
                timestamp: Timestamp()
            )
            
            UserService.shared.setVocabulary(vocabulary!) { error, id in
                if let error = error {
                    UserService.shared.db.handleFirestoreError(error, viewController: self)
                    self.progressHUD.hide()
                    return
                }
                guard let id = id else { return }
                self.vocabulary!.id = id
                self.completeSaving(vocabulary: self.vocabulary!)
            }
        } else {
            guard var vocabulary = self.vocabulary else { return }
            
            vocabulary.title = title
            vocabulary.language = language

            UserService.shared.updateVocabulary(vocabulary) { error, index in
                if let error = error {
                    UserService.shared.db.handleFirestoreError(error, viewController: self)
                    self.progressHUD.hide()
                    return
                }
                self.completeSaving(vocabulary: vocabulary, index: index)
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
