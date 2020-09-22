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
    
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var progressHUD = ProgressHUD(title: "Saving")
    var vocabulary: Vocabulary?
    var isFirstSelected = true
    
    private var isKeyboardShowing = false
    private var keyboardHeight: CGFloat!
    private var languages: [String] = []
    private var languageIndex: Int?
    
    weak var delegate: VocabularyDetailsVCDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Primary setting up UI
        getAllLanguages()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(currentVocabularyDidUpdate), name: NSNotification.Name(Keys.currentVocabularyDidUpdateKey), object: nil)
        nc.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // TextField observers
        titleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        languageTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
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
    
    @objc func currentVocabularyDidUpdate() {
        print("notification has been sent - currentVocabularyDidUpdate")
    }
    
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
    
    private func getAllLanguages() {
        for code in NSLocale.isoLanguageCodes  {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.languageCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en").displayName(forKey: NSLocale.Key.identifier, value: id) ?? ""
            if name != "" {
                languages.append(name)
            }
        }
        languages.sort()
        languages.append("Other")
    }
    
    private func setupUI() {
        hideKeyboardWhenTappedAround()
        
        languageTextField.isHidden = true
        
        titleTextField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        titleTextField.delegate = self
        
        // spinner
        view.addSubview(progressHUD)
        progressHUD.hide()
        titleTextField?.autocorrectionType = .no
        languageTextField?.autocorrectionType = .no
        
        guard let title = vocabulary?.title, let language = vocabulary?.language else { return }
        if title.isNotEmpty && language.isNotEmpty {
            titleTextField.text = title
            if languages.contains(where: { $0 == language }) {
                languageButton.setTitle(language, for: .normal)
            } else {
                languageButton.setTitle(languages[languages.count - 1], for: .normal)
                languageTextField.text = language
                languageTextField.isHidden = false
            }
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
    
    private func onSave() {
        guard let title = titleTextField.text, title.isNotEmpty, let language = languageTextField.text, language.isNotEmpty else { return }
        
        // validation - same vocabulary
        let vocabularies = UserService.shared.vocabularies
        if vocabularies.contains(where: { $0.title.lowercased() == title.lowercased() && $0.language.lowercased() == language.lowercased() }) {
            simpleAlert(title: "Vocabulary is already exist", msg: "You have already the same vocabulary. Make different one.") { _ in
                self.titleTextField.becomeFirstResponder()
                self.disableAllButtons()
            }
            return
        }

        // if all is good then start spinner
        progressHUD.show()
        
        if vocabulary == nil {
            createVocabulary(title: title, language: language)
        } else {
            updateVocabulary(title: title, language: language)
        }
    }
    
    private func createVocabulary(title: String, language: String) {
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
    }
    
    private func updateVocabulary(title: String, language: String) {
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
    
    // MARK: - IBActions
    
    @IBAction func cancelTapped(_ sender: UIButton) { onCancel() }
    @IBAction func saveTapped(_ sender: UIButton) { onSave() }
    
    // MARK: - Override
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tvc = segue.destination as? CheckmarkListTVC {
            tvc.delegate = self
            tvc.data = languages
            tvc.title = "Select language"
            
            guard let vocabulary = self.vocabulary else { return }
            if vocabulary.language.isNotEmpty {
                if languages.contains(where: {$0 == vocabulary.language}) {
                    tvc.selected = languages.firstIndex(where: {$0 == vocabulary.language})
                } else {
                    tvc.selected = languages.count - 1
                }
            }
        }
    }
}

extension VocabularyDetailsVC: CheckmarkListTVCDelegate {
    func getCheckmared(index: Int) {
        languageButton.setTitle(languages[index], for: .normal)
        self.languageIndex = index
        
        if index == languages.count - 1 {
            languageTextField.isHidden = false
            languageTextField.becomeFirstResponder()
            buttonsStackView.alpha = 1
        } else {
            languageTextField.isHidden = true
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

extension VocabularyDetailsVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text, let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 26
    }
}
