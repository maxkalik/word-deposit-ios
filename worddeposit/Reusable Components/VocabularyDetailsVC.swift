import UIKit
import FirebaseFirestore

protocol VocabularyDetailsVCDelegate: AnyObject {
    func vocabularyDidCreate(_ vocabulary: Vocabulary)
    func vocabularyDidUpdate(_ vocabulary: Vocabulary, index: Int)
}

class VocabularyDetailsVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    @IBOutlet weak var titleTextField: PrimaryTextField!
    @IBOutlet weak var languageTextField: UITextField!
    
    @IBOutlet weak var languageButton: ButtonSelector!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var cancelButton: SecondaryButton!
    @IBOutlet weak var saveButton: SecondaryButton!
    
    private var progressHUD = ProgressHUD(title: "Saving")
    private var messageView = MessageView()
    var vocabulary: Vocabulary?
    var isFirstSelected = true
    
    private var isKeyboardShowing = false
    private var keyboardHeight: CGFloat!
    private var languages: [String] = []
    private var languageIndex: Int? {
        didSet {
            guard let title = titleTextField.text, let index = languageIndex else { return }
            if index != oldValue {
                buttonsStackView.alpha = 1
                if title.isEmpty {
                    disableOnlySaveButton()
                } else {
                    if index == languages.count - 1 {
                        guard let language = languageTextField.text else { return }
                        if language.isEmpty { disableOnlySaveButton() }
                    } else {
                        enableAllButtons()
                    }
                }
            } else {
                buttonsStackView.alpha = 0
                disableAllButtons()
            }
        }
    }
    private var isLimitVocabularies = UserService.shared.vocabularies.count < Limits.vocabularies
    weak var delegate: VocabularyDetailsVCDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.silver
        
        // Primary setting up UI
        getLanguages()
        setupUI()
        disableAllButtons()

        if vocabulary != nil {
            buttonsStackView.alpha = 0
        } else {
            view.addSubview(messageView)
            cancelButton.setTitle("Clear", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(currentVocabularyDidUpdate), name: NSNotification.Name(Keys.currentVocabularyDidUpdateKey), object: nil)
        nc.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        titleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        languageTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        if isLimitVocabularies {
            messageView.hide()
        } else {
            setupMessage()
            messageView.show()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if languageIndex != languages.count - 1 && isLimitVocabularies {
            titleTextField.becomeFirstResponder()
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
            scrollView.contentOffset.y = keyboardHeight
        }
        
        buttonsStackView.alpha = 1
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if !isKeyboardShowing { return }
        isKeyboardShowing = false
        if vocabulary != nil { buttonsStackView.alpha = 0 }
    }
    
    private func getLanguage() -> String {
        guard let index = languageIndex else { return "" }
        if index == languages.count - 1 {
            guard let languageFromTextField = languageTextField.text else { return "" }
            return languageFromTextField
        } else {
            return languages[index]
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        guard let title = titleTextField.text else { return }

        let language = getLanguage()
        
        // if vocabulary is creating new
        guard let vocabulary = self.vocabulary else {
            if title.isNotEmpty && languageIndex != nil {
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
    
    private func setupMessage() {
        messageView.setTitles(
            messageTxt: "Vocabularies limit exceeded.\n",
            buttonTitle: "Continue"
        )
        messageView.onPrimaryButtonTap { self.navigationController?.popViewController(animated: true) }
    }
    
    private func getLanguages() {
        // Get default languages and appen them to languages array
        for code in NSLocale.isoLanguageCodes  {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.languageCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en").displayName(forKey: NSLocale.Key.identifier, value: id) ?? ""
            if name != "" { languages.append(name) }
        }
        
        // Sort them
        languages.sort()
        
        // Add custom languages from created vocabularies to the beginning of the array
        for vocabulary in UserService.shared.vocabularies {
            if vocabulary.language.isNotEmpty && !languages.contains(vocabulary.language) {
                languages.insert(vocabulary.language, at: 0)
            }
        }
        
        // Add "Other" to the end of the array
        languages.append("Other")
    }
    
    private func setupUI() {
        hideKeyboardWhenTappedAround()
        
        // Limits of text in the text intput comes from extension
        titleTextField.limitOfString = Limits.vocabularyTitle
        
        // Spinner
        view.addSubview(progressHUD)
        progressHUD.hide()
        
        setupContent()
    }
    
    private func setupContent() {
        guard let title = vocabulary?.title, let language = vocabulary?.language else {
            languageTextField.isHidden = true
            return
        }
        if title.isNotEmpty && language.isNotEmpty {
            titleTextField.text = title
            
            // setup languages
            if languages.contains(where: { $0 == language }) {
                languageIndex = languages.firstIndex(where: { $0 == language })
                languageButton.setTitle(language, for: .normal)
                languageTextField.isHidden = true
            } else {
                languageIndex = languages.count - 1
                languageButton.setTitle(languages[languageIndex!], for: .normal)
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
        dismissKeyboard()
        isKeyboardShowing = false
        languageButton.isHidden = false
        
        if vocabulary != nil {
            setupContent()
            buttonsStackView.alpha = 0
            disableAllButtons()
            return
        }
        
        titleTextField.text = ""
        languageTextField.text = ""
        languageTextField.isHidden = true
        languageIndex = nil
        languageButton.setTitle("Select language", for: .normal)
        disableAllButtons()
    }
    
    private func onSave() {
        let language = getLanguage()
        guard let title = titleTextField.text, title.isNotEmpty, language.isNotEmpty else { return }
        
        let vocabularies = UserService.shared.vocabularies
        if vocabularies.contains(where: {
                                    $0.title.lowercased() == title.lowercased()
                                 && $0.id != self.vocabulary?.id
                                 && $0.language.lowercased() == language.lowercased()
        }) {
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
            
            titleTextField.resignFirstResponder()
            
            guard let vocabulary = self.vocabulary else { return }
            if languageIndex != nil {
                tvc.selected = languageIndex
            } else {
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
}

extension VocabularyDetailsVC: CheckmarkListTVCDelegate {
    func getCheckmared(index: Int) {
        if languageIndex != index {
            languageButton.setTitle(languages[index], for: .normal)
            languageIndex = index
            
            if index == languages.count - 1 {
                // OTHER CASE
                languageButton.isHidden = true
                languageTextField.isHidden = false
                titleTextField.resignFirstResponder()
                languageTextField.becomeFirstResponder()
            } else {
                languageTextField.isHidden = true
                languageButton.isHidden = false
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
    
    private func disableOnlySaveButton() {
        saveButton.isEnabled = false
        cancelButton.isEnabled = true
    }
}
