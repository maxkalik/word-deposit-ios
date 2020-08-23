import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import Kingfisher
import YPImagePicker

protocol VocabularyCardCVCellDelegate: AnyObject {
    func showAlert(title: String, message: String)
    func presentVC(_ viewControllerToPresent: UIViewController)
    func disableEnableScroll(isKeyboardShow: Bool)
}

class VocabularyCardCVCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var wordImageButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var wordExampleTextField: UITextField!
    @IBOutlet weak var wordTranslationTextField: UITextField!
    @IBOutlet weak var wordDescriptionTextField: UITextField!
    @IBOutlet weak var saveChangingButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    // MARK: - Variables

    var vocabularyId: String!
    var word: Word!
    var wordRef: DocumentReference!
    var auth = Auth.auth()
    var db = Firestore.firestore()
    var storage = Storage.storage()
    lazy var currentUser = auth.currentUser
    // private var isImageSet = false
    private var isKeyboardShowing = false
    
    weak var delegate: VocabularyCardCVCellDelegate?
    
    // MARK: - View Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        wordImageButton.setImage(UIImage(named: Placeholders.Logo), for: .normal)
        
        hideAllButtons()
        disableAllButtons()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        frame.size.height -= 40
        
        hideAllButtons()
        disableAllButtons()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        addGestureRecognizer(tap)
        
        wordExampleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        wordTranslationTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        wordDescriptionTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        wordExampleTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        wordTranslationTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        wordDescriptionTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    // MARK: - @objc methods
    
    @objc func dismissKeyboard() {
        endEditing(true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        textFieldValidation()
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        
        if isKeyboardShowing { return }
        isKeyboardShowing = true
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight: CGFloat = keyboardFrame.cgRectValue.height
            showAllButtons()
            frame.origin.y -= keyboardHeight
        }
        
        UIView.animate(withDuration: 0.3) {
            self.wordImageButton.alpha = 0
        }
        
        delegate?.disableEnableScroll(isKeyboardShow: true)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        
        if !isKeyboardShowing { return }
        isKeyboardShowing = false
        frame.origin.y = 0
        hideAllButtons()
        
        UIView.animate(withDuration: 0.3) {
            self.wordImageButton.alpha = 1
        }
        
        delegate?.disableEnableScroll(isKeyboardShow: false)
    }
    
    // MARK: - Other methods
    
    func textFieldValidation() {
        guard let wordExample = wordExampleTextField.text,
            let wordTranslation = wordTranslationTextField.text,
            let wordDescription = wordDescriptionTextField.text else { return }
        
        if wordExample != word.example
            || wordTranslation != word.translation
            || wordDescription != word.description
        {
            enableAllButtons()
            if wordExample.isEmpty || wordTranslation.isEmpty {
                cancelButton.isEnabled = true
                saveChangingButton.isEnabled = false
            }
        } else {
            disableAllButtons()
        }
    }
    
    func configureCell(vocabularyId: String, word: Word, delegate: VocabularyCardCVCellDelegate) {
        self.vocabularyId = vocabularyId
        self.word = word
        self.delegate = delegate
        setupWord(word)
    }
    
    func setupWord(_ word: Word) {
        if let url = URL(string: word.imgUrl) {
            wordImageButton.imageView?.kf.indicatorType = .activity
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
            let imgRecourse = ImageResource(downloadURL: url, cacheKey: word.imgUrl)
            wordImageButton.kf.setImage(with: imgRecourse, for: .normal, options: options)
        }
        wordExampleTextField.text = word.example
        wordTranslationTextField.text = word.translation
        wordDescriptionTextField.text = word.description
    }
    
    // MARK: - IBActions
    
    @IBAction func wordImageButtonTouched(_ sender: UIButton) {
        let ypConfig = YPImagePickerConfig()
        let picker = YPImagePicker(configuration: ypConfig.defaultConfig())

        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                // self.isImageSet = true
                self.wordImageButton.setImage(photo.image, for: .normal)
                // self.textFieldValidation()
                
                self.uploadImage()
            }
            picker.dismiss(animated: true, completion: nil)
        }
        self.delegate?.presentVC(picker)
        
    }

    @IBAction func onSaveChangingTouched(_ sender: UIButton) {
        loader.startAnimating()
        uploadWord()
        disableAllButtons()
    }
    
    @IBAction func onCancelTouched(_ sender: UIButton) {
        self.setupWord(word)
        disableAllButtons()
        // isImageSet = false
    }
    
    func prepareForUpload() {

        // TODO: shoud be rewrited in the singleton
        guard let user = currentUser, let vocabularyId = self.vocabularyId else { return }
        let vocabularyRef: DocumentReference = db.collection("users").document(user.uid).collection("vocabularies").document(vocabularyId)
        wordRef = vocabularyRef.collection("words").document(word.id)

    }
    
    func uploadImage() {

        guard let user = currentUser, let image = wordImageButton.imageView?.image, let vocabularyId = self.vocabularyId else {
            self.delegate?.showAlert(title: "Error", message: "Fields cannot be empty")
            loader.stopAnimating()
            return
        }
        
        let imgRef = "/\(user.uid)/\(vocabularyId)/"
        
        // remove previous image before uploading is an object have it
        if word.imgUrl.isNotEmpty {
            self.storage.reference().child("\(imgRef)\(word.id).jpg").delete { (error) in
                if let error = error {
                    self.delegate?.showAlert(title: "Error", message: error.localizedDescription)
                    debugPrint(error.localizedDescription)
                    return
                }
            }
        }
        
        let resizedImg = image.resized(toWidth: 400.0)
        guard let imageData = resizedImg?.jpegData(compressionQuality: 0.5) else { return }
        
        let imageRef = Storage.storage().reference().child("/\(imgRef)/\(word.id).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        imageRef.putData(imageData, metadata: metadata) { (storageMetadata, error) in
            if let error = error {
                self.delegate?.showAlert(title: "Error", message: "Unable to upload image")
                debugPrint(error.localizedDescription)
                return
            }
            
            imageRef.downloadURL { (url, error) in
                if let error = error {
                    self.delegate?.showAlert(title: "Error", message: "Unable to upload image")
                    debugPrint(error.localizedDescription)
                    return
                }
                guard let url = url else { return }
                let imgUrl = url.absoluteString
                
                self.prepareForUpload()
                
                self.wordRef.updateData(["img_url" : imgUrl]) { error in
                    if let error = error {
                        self.delegate?.showAlert(title: "Error", message: error.localizedDescription)
                    } else {
                        self.word.imgUrl = imgUrl
                        self.delegate?.showAlert(title: "Success", message: "Pitcure has been updated")
                    }
                    self.loader.stopAnimating()
                }
            }
        }
    }
    
    func uploadWord() {
        
        guard let example = wordExampleTextField.text, example.isNotEmpty,
            let translation = wordTranslationTextField.text, translation.isNotEmpty
            else {
                self.delegate?.showAlert(title: "Error", message: "Fields cannot be empty")
                return
        }
        
        guard let description = wordDescriptionTextField.text else { return }
        
        // Making a copy of the word
        var updatedWord = word!
        updatedWord.example = example
        updatedWord.translation = translation
        if description.isNotEmpty {
            updatedWord.description = description
        }
        
        let data = Word.modelToData(word: updatedWord)

        self.prepareForUpload()
        
        wordRef.updateData(data) { error in
            if let error = error {
                self.delegate?.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                self.word = updatedWord
                self.hideAllButtons()
                self.dismissKeyboard()
                self.delegate?.showAlert(title: "Success", message: "Word has been updated")
            }
            self.loader.stopAnimating()
        }
    }
}

extension VocabularyCardCVCell {
    func hideAllButtons() {
        saveChangingButton.isHidden = true
        cancelButton.isHidden = true
    }
    
    func showAllButtons() {
        saveChangingButton.isHidden = false
        cancelButton.isHidden = false
    }
    
    func enableAllButtons() {
        cancelButton.isEnabled = true
        saveChangingButton.isEnabled = true
    }
    
    func disableAllButtons() {
        cancelButton.isEnabled = false
        saveChangingButton.isEnabled = false
    }
}
