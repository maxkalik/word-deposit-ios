import UIKit
import YPImagePicker

protocol AddWordVCDelegate: AnyObject {
    func wordDidCreate(_ word: Word)
}

class AddWordVC: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    @IBOutlet weak var inputsView: UIView!
    
    @IBOutlet weak var wordImageButton: UIButton! {
        didSet {
            wordImageButton.imageView?.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var wordSaveButton: PrimaryButton!
    @IBOutlet weak var clearAllButton: DefaultButton!
    @IBOutlet weak var wordExampleTextField: PrimaryTextField!
    @IBOutlet weak var wordTranslationTextField: PrimaryTextField!
    @IBOutlet weak var wordDescriptionTextField: SecondaryTextField!
    
    // MARK: - Instances
    
    private var progressHUD = ProgressHUD(title: "Saving")
    private var messageView = MessageView()
    private var isImageSet = false
    private var isKeyboardShowing = false
    
    weak var delegate: AddWordVCDelegate?
    
    private var inputViewOriginY: CGFloat!
    private var wordImagePickerBtnOriginY: CGFloat!
    private var isLimitWords = UserService.shared.words.count < Limits.words
    
    // private var wordsCount: Int
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImagePlaceholder()
        wordExampleTextField.limitOfString = Limits.wordExample
        wordTranslationTextField.limitOfString = Limits.wordTranslation
        wordDescriptionTextField.limitOfString = Limits.wordDescription
        
        setupUI()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isLimitWords {
            messageView.hide()
        } else {
            setupMessage()
            messageView.show()
        }
        
        wordExampleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        wordTranslationTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isLimitWords {
            wordExampleTextField.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        wordExampleTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        wordTranslationTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    // MARK: - @objc Methods
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        
        if isKeyboardShowing { return }
        isKeyboardShowing = true
        
        closeButton.setImage(UIImage(named: "icon_close_large"), for: .normal)
        let topSafeArea: CGFloat = view.safeAreaInsets.top
        
        // Set initial values
        inputViewOriginY = inputsView.frame.origin.y
        wordImagePickerBtnOriginY = wordImageButton.frame.origin.y
        
        // Disable scroll to prevent breaking layout
        scrollView.isScrollEnabled = false
        
        // Scale WordImagePickerBtn
        wordImageButton.transform = CGAffineTransform(scaleX: 0.3, y: 0.3);
        wordImageButton.imageView?.layer.transform = CATransform3DScale(CATransform3DIdentity, 2.0, 2.0, 2.0)
        wordImageButton.layer.cornerRadius = 50.0
        wordImageButton.frame.origin.y = topSafeArea + 20
        
        // Move inputsView close to wordImagePickerBtn
        inputsView.frame.origin.y = topSafeArea + wordImageButton.frame.size.height + 20
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        
        if !isKeyboardShowing { return }
        isKeyboardShowing = false
        
        closeButton.setImage(UIImage(named: "icon_close_large_bordered"), for: .normal)
        // Return default state of wordImagePickerBtn
        wordImageButton.transform = CGAffineTransform(scaleX: 1, y: 1);
        wordImageButton.imageView?.layer.transform = CATransform3DIdentity
        wordImageButton.layer.cornerRadius = 0.0
        wordImageButton.frame.origin.y = wordImagePickerBtnOriginY

        // Return default Y value of inputsView
        inputsView.frame.origin.y = inputViewOriginY
        
        // Enabe scrollView
        scrollView.isScrollEnabled = true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let wordExample = wordExampleTextField.text,
              let wordTranslation = wordTranslationTextField.text else { return }
        wordSaveButton.isEnabled = !(wordExample.isEmpty || wordTranslation.isEmpty)
        clearAllButton.isEnabled = !(wordExample.isEmpty && wordTranslation.isEmpty)
        wordDescriptionTextField.isHidden = wordExample.isEmpty || wordTranslation.isEmpty
    }
    
    // MARK: - Support Methods
    
    private func setupImagePlaceholder() {
        wordImageButton.backgroundColor = Colors.lightDark
        let image = UIImage(named: Icons.Photo)?.withRenderingMode(.alwaysTemplate)
        wordImageButton.setImage(image, for: .normal)
        wordImageButton.tintColor = Colors.grey.withAlphaComponent(0.3)
    }
    
    private func setupMessage() {
        messageView.setTitles(
            messageTxt: "Words limit exceeded.\n Remove unnecessary words\nor create new vocabulary.\n",
            buttonTitle: "Continue"
        )
        messageView.onPrimaryButtonTap { self.dismiss(animated: true, completion: nil) }
    }
    
    private func setupUI() {
        view.addSubview(progressHUD)
        view.addSubview(messageView)
        progressHUD.hide()
        messageView.hide()
        
        view.backgroundColor = Colors.silver
        
        wordDescriptionTextField.isHidden = true
        wordDescriptionTextField.textColor = Colors.darkGrey
        wordSaveButton.isEnabled = false
        clearAllButton.isEnabled = false
        
        wordSaveButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    private func successComplition(word: Word?) {
        guard let word = word else { return }
        updateUI()
        delegate?.wordDidCreate(word)
    }
    
    private func setImageData() -> Data? {
        if isImageSet {
            guard let image = wordImageButton.imageView?.image else { return nil }
            let resizedImg = image.resized(toWidth: 400.0)
            return resizedImg?.jpegData(compressionQuality: 0.5)
        }
        return nil
    }
    
    private func prepareForUpload() {
        guard let example = wordExampleTextField.text, example.isNotEmpty,
            let translation = wordTranslationTextField.text, example.isNotEmpty else {
                simpleAlert(title: "Error", msg: "Fill all fields")
                progressHUD.hide()
                return
        }
        
        if UserService.shared.words.contains(where: { $0.example.lowercased() == example.lowercased() && $0.translation.lowercased() == translation.lowercased() }) {
            simpleAlert(title: "You have already this word", msg: " \(example) is already exist. Try to make another one") { _ in
                self.wordExampleTextField.becomeFirstResponder()
                self.progressHUD.hide()
            }
        } else {
            // TODO: - try to make this process in background (without canceling on the dismissing view)
            // TODO: - BUG - freazing while typing word
            progressHUD.show()
            
            UserService.shared.setWord(
                imageData: setImageData(),
                example: example,
                translation: translation,
                description: wordDescriptionTextField.text
            ) { error, word in
                if error != nil {
                    self.progressHUD.hide()
                    self.simpleAlert(title: "Error", msg: "Something went wrong. Cannot add the word")
                    return
                }
                self.progressHUD.success(with: "Added")
                self.successComplition(word: word)
            }
        }
    }
    
    func hideKeyboard() {
        dismissKeyboard()
        isKeyboardShowing = false
        wordExampleTextField.resignFirstResponder()
        wordTranslationTextField.resignFirstResponder()
        wordDescriptionTextField.resignFirstResponder()
        view.endEditing(true)
    }
    
    func updateUI() {
        hideKeyboard()
        wordDescriptionTextField.isHidden = true

        setupImagePlaceholder()
        wordExampleTextField.text = ""
        wordTranslationTextField.text = ""
        wordDescriptionTextField.text = ""
        
        isImageSet = false
        wordSaveButton.isEnabled = false
        clearAllButton.isEnabled = false
    }
    
    // MARK: - IBActions
    
    @IBAction func wordImagePickerBtnTapped(_ sender: UIButton) {
        let ypConfig = YPImagePickerConfig()
        if isImageSet == true {
            ypConfig.config.startOnScreen = YPPickerScreen.library
        }
        let picker = YPImagePicker(configuration: ypConfig.defaultConfig())

        // unowned picker will help to avoid memory leak on each action
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.wordImageButton.setImage(photo.image, for: .normal)
                self.isImageSet = true
                self.clearAllButton.isEnabled = true
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func onAddWordBtnPress(_ sender: UIButton) {
        if UserService.shared.words.count < Limits.words {
            prepareForUpload()
        } else {
            simpleAlert(title: "Words limit exceeded", msg: "Remove unnecessary words\nor create new vocabulary.\n")
        }
    }
    
    @IBAction func onClearAllBtnPress(_ sender: UIButton) {
        updateUI()
    }
    
    @IBAction func closeButtonPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - ScrollViewDelegate

extension AddWordVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let transform = ScrollViewHelper.shared.transformOnScroll(with: scrollView.contentOffset, and: wordImageButton.frame.size.height)
        wordImageButton.layer.transform = transform
    }
}
