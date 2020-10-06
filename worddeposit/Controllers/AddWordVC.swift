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
            // this will allow to put content view to the scroll without including safearea in the top
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    @IBOutlet weak var inputsView: UIView!
    
    @IBOutlet weak var wordImagePickerBtn: UIButton! {
        didSet {
            wordImagePickerBtn.imageView?.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var wordSaveButton: PrimaryButton!
    @IBOutlet weak var clearAllButton: DefaultButton!
    @IBOutlet weak var wordExampleTextField: PrimaryTextField!
    @IBOutlet weak var wordTranslationTextField: SecondaryTextField!
    @IBOutlet weak var wordDescriptionTextField: SecondaryTextField!
    
    // MARK: - Instances
    
    private var progressHUD = ProgressHUD(title: "Saving")
    private var messageView = MessageView()
    private var isImageSet = false
    private var isKeyboardShowing = false
    
    weak var delegate: AddWordVCDelegate?
    
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
        
        if UserService.shared.words.count > Limits.words {
            messageView.show()
            setupMessage()
        } else {
            messageView.hide()
        }
        
        wordExampleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        wordTranslationTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        
        let topSafeArea: CGFloat = view.safeAreaInsets.top
            
        inputsView.frame.origin.y = topSafeArea + 20
        scrollView.isScrollEnabled = false

        UIView.animate(withDuration: 0.3) {
            self.wordImagePickerBtn.alpha = 0
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        
        if !isKeyboardShowing { return }
        isKeyboardShowing = false
        
        inputsView.frame.origin.y = 375
        scrollView.isScrollEnabled = true

        UIView.animate(withDuration: 0.3) {
            self.wordImagePickerBtn.alpha = 1
        }
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
        wordImagePickerBtn.backgroundColor = UIColor.black
        let image = UIImage(named: Icons.Picture)?.withRenderingMode(.alwaysTemplate)
        wordImagePickerBtn.setImage(image, for: .normal)
        wordImagePickerBtn.tintColor = Colors.grey.withAlphaComponent(0.3)
    }
    
    private func setupMessage() {
        messageView.setTitles(
            messageTxt: "Words limit exceeded.\n",
            buttonTitle: "Continue",
            secondaryButtonTitle: "Logout"
        )
        // push to vocabulary view
        messageView.onPrimaryButtonTap { self.tabBarController?.selectedIndex = 2 }
    }
    
    private func setupUI() {
        view.addSubview(progressHUD)
        view.addSubview(messageView)
        progressHUD.hide()
        messageView.hide()
        
        view.backgroundColor = Colors.silver
        
        wordDescriptionTextField.isHidden = true
        wordExampleTextField.autocorrectionType = .no
        wordTranslationTextField.autocorrectionType = .no
        wordDescriptionTextField.autocorrectionType = .no
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
        if self.isImageSet {
            guard let image = wordImagePickerBtn.imageView?.image else { return nil }
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
            return
        }
        
        // TODO: - try to make this process in background (without canceling on the dismissing view)
        // TODO: - BUG - freazing while typing word
        
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.progressHUD.hide()
            }
            self.successComplition(word: word)
        }
    }
    
    
    func updateUI() {
        // TODO: - not showing message while adding
        
        dismissKeyboard()
        isKeyboardShowing = false
        wordDescriptionTextField.isHidden = true
        
        if UserService.shared.words.count > Limits.words {
            DispatchQueue.main.async {
                self.messageView.show()
                self.setupMessage()
            }
        }
        
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
        let picker = YPImagePicker(configuration: ypConfig.defaultConfig())

        // unowned picker will help to avoid memory leak on each action
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.wordImagePickerBtn.setImage(photo.image, for: .normal)
                self.isImageSet = true
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func onAddWordBtnPress(_ sender: UIButton) {
        progressHUD.show()
        prepareForUpload()
    }
    
    @IBAction func onClearAllBtnPress(_ sender: UIButton) {
        updateUI()
    }
}

// MARK: - ScrollViewDelegate

extension AddWordVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // make image scale on scroll
        let offset = scrollView.contentOffset

        if offset.y < 0.0 {
            var transform = CATransform3DTranslate(CATransform3DIdentity, 0, (offset.y), 0)
            let scaleFactor = 1 + (-1 * offset.y / (wordImagePickerBtn.frame.size.height / 2))
            transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1)
            wordImagePickerBtn.layer.transform = transform
        } else {
            wordImagePickerBtn.layer.transform = CATransform3DIdentity
        }
    }
}
