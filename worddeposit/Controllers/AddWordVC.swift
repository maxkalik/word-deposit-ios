import UIKit
import YPImagePicker

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
    
    @IBOutlet weak var wordSaveButton: RoundedButton!
    @IBOutlet weak var clearAllButton: UIButton!
    @IBOutlet weak var wordExampleTextField: UITextField!
    @IBOutlet weak var wordTranslationTextField: UITextField!
    @IBOutlet weak var wordDescriptionTextField: UITextField!
    
    // MARK: - Instances
    
    var progressHUD = ProgressHUD(title: "Saving")
    private var isImageSet = false
    private var isKeyboardShowing = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        textFieldValidation()
    }
    
    // MARK: - Support Methods
    
    func textFieldValidation() {
        guard let wordExample = wordExampleTextField.text,
              let wordTranslation = wordTranslationTextField.text else { return }
        wordSaveButton.isEnabled = !(wordExample.isEmpty || wordTranslation.isEmpty)
        clearAllButton.isEnabled = !(wordExample.isEmpty && wordTranslation.isEmpty)
    }
    
    private func setupUI() {
        view.addSubview(progressHUD)
        progressHUD.hide()
        wordExampleTextField.autocorrectionType = .no
        wordTranslationTextField.autocorrectionType = .no
        wordDescriptionTextField.autocorrectionType = .no
        wordSaveButton.isEnabled = false
        clearAllButton.isEnabled = false
    }
    
    func prepareForUpload() {
        guard let example = wordExampleTextField.text, example.isNotEmpty,
            let translation = wordTranslationTextField.text, example.isNotEmpty else {
                simpleAlert(title: "Error", msg: "Fill all fields")
                progressHUD.hide()
                return
        }
        guard let description = wordDescriptionTextField.text else { return }
        
        if self.isImageSet {
            
            guard let image = wordImagePickerBtn.imageView?.image else {
                simpleAlert(title: "Error", msg: "Fill all fields")
                progressHUD.hide()
                return
            }
            let resizedImg = image.resized(toWidth: 400.0)
            guard let imageData = resizedImg?.jpegData(compressionQuality: 0.5) else { return }
            
            UserService.shared.setWord(imageData: imageData, example: example, translation: translation, description: description) {
                self.updateUI()
                self.progressHUD.hide()
                self.simpleAlert(title: "Success", msg: "Word has been added with image")
            }
            
        } else {
            UserService.shared.setWord(example: example, translation: translation, description: description) {
                self.updateUI()
                self.progressHUD.hide()
                self.simpleAlert(title: "Success", msg: "Word has been added")
            }
        }
    }
    
    
    func updateUI() {
        self.wordImagePickerBtn.setImage(UIImage(named: Placeholders.Logo), for: .normal)
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
    
    @IBAction func onAddWordBtnPress(_ sender: Any) {
        progressHUD.show()
        prepareForUpload()
    }
    
    @IBAction func onClearAllBtnPress(_ sender: Any) {
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
