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

    @IBOutlet weak var wordImageButton: UIButton! {
        didSet {
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(adjustImageButtonScale(byHandlingGestureRecognizedBy:)))
            wordImageButton.addGestureRecognizer(pinch)
            wordImageButton.imageView?.contentMode = .scaleAspectFill
        }
    }
    @IBOutlet weak var wordExampleTextField: UITextField!
    @IBOutlet weak var wordTranslationTextField: UITextField!
    @IBOutlet weak var saveChangingButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var loader: RoundedView!
    
    // MARK: - Variables

    var word: Word!
    var wordRef: DocumentReference!
    var db = Firestore.firestore()
    var storage = Storage.storage()
    private var isImageSet = false
    var wordImageButtonScale: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    weak var delegate: VocabularyCardCVCellDelegate?
    
    // MARK: - View Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        wordImageButton.setImage(UIImage(named: Placeholders.Logo), for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loader.isHidden = true
        saveChangingButton.isHidden = true
        cancelButton.isHidden = true
        
        wordExampleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        wordTranslationTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        wordExampleTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        wordTranslationTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    // MARK: - @objc methods
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        textFieldValidation()
    }
    
    @objc func keyboardWillShow(sender: UIResponder) {
        // self.view.frame.origin.y -= 150
//        self.frame.origin.y -= 150
        delegate?.disableEnableScroll(isKeyboardShow: true)
        print("keyboard show")
        
        print(frame.size.width, UIScreen.main.bounds.width)
        print(frame.size.height, UIScreen.main.bounds.height)
    }
    
    @objc func keyboardWillHide(sender: UIResponder) {
        print("keyboard hide")
        delegate?.disableEnableScroll(isKeyboardShow: false)
    }
    
    @objc func adjustImageButtonScale(byHandlingGestureRecognizedBy recoginzer: UIPinchGestureRecognizer) {
        switch recoginzer.state {
        case .changed:
            wordImageButtonScale *= recoginzer.scale
            recoginzer.scale = 1.0
        case .ended:
            wordImageButtonScale = 1.0
        default: break
        }
    }
    
    // MARK: - Override methods
    
    override func draw(_ rect: CGRect) {
        wordImageButton.transform = CGAffineTransform(scaleX: wordImageButtonScale, y: wordImageButtonScale)
    }
    
    // MARK: - Other methods
    
    func hideAllButtons(_ isShow: Bool) {
        saveChangingButton.isHidden = isShow
        cancelButton.isHidden = isShow
    }
    
    func textFieldValidation() {
        guard let wordExample = wordExampleTextField.text, let wordTranslation = wordTranslationTextField.text else { return }
        
        if wordExample != word.example || wordTranslation != word.translation || isImageSet {
            hideAllButtons(false)
            if wordExample.isEmpty || wordTranslation.isEmpty {
                saveChangingButton.isHidden = true
                cancelButton.isHidden = false
            }
        } else {
            hideAllButtons(true)
        }
    }
    
    func configureCell(word: Word, delegate: VocabularyCardCVCellDelegate) {
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
    }
    
    // MARK: - IBActions
    
    @IBAction func wordImageButtonTouched(_ sender: UIButton) {
        let ypConfig = YPImagePickerConfig()
        let picker = YPImagePicker(configuration: ypConfig.defaultConfig())

        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.isImageSet = true
                self.wordImageButton.setImage(photo.image, for: .normal)
                
                self.textFieldValidation()
                
            }
            picker.dismiss(animated: true, completion: nil)
        }
        self.delegate?.presentVC(picker)
        
    }

    @IBAction func onSaveChangingTouched(_ sender: UIButton) {
        self.loader.isHidden = false
        prepareForUpload()
    }
    
    @IBAction func onCancelTouched(_ sender: UIButton) {
        self.setupWord(word)
        hideAllButtons(true)
        isImageSet = false
    }
    
    func prepareForUpload() {
        guard let example = wordExampleTextField.text, example.isNotEmpty,
            let translation = wordTranslationTextField.text, translation.isNotEmpty
            else {
                self.delegate?.showAlert(title: "Error", message: "Fields cannot be empty")
                return
        }
        
        // TODO: shoud be rewrited in the singleton
        guard let user = Auth.auth().currentUser else { return }
        wordRef = db.collection("users").document(user.uid).collection("words").document(word.id)
        
        // Making a copy of the word
        var updatedWord = word!
        updatedWord.example = example
        updatedWord.translation = translation
        
        if isImageSet {
            // if only image has been changed?
            uploadImage(userId: user.uid, updatedWord: word)
        } else {
            uploadWord(updatedWord)
        }
    }
    
    /* ********* */
    // check
    func uploadImage(userId: String, updatedWord: Word) {
        
        guard let image = wordImageButton.imageView?.image else {
            self.delegate?.showAlert(title: "Error", message: "Fields cannot be empty")
            loader.isHidden = true
            return
        }
        
        // remove image before uploading
        if word.imgUrl.isNotEmpty {
            self.storage.reference().child("/\(userId)/\(word.id).jpg").delete { (error) in
                if let error = error {
                    self.delegate?.showAlert(title: "Error", message: error.localizedDescription)
                    debugPrint(error.localizedDescription)
                    return
                }
            }
        }
        
        var updatedWord = updatedWord // convert let to var
        
        let resizedImg = image.resized(toWidth: 400.0)
        guard let imageData = resizedImg?.jpegData(compressionQuality: 0.5) else { return }
        
        let imageRef = Storage.storage().reference().child("/\(userId)/\(updatedWord.id).jpg")
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
                updatedWord.imgUrl = url.absoluteString
                
                // updating wordUrl
                // TODO - should have to own func to update just url may be
                self.uploadWord(updatedWord)
            }
        }
    }
    
    func uploadWord(_ word: Word) {
        let data = Word.modelToData(word: word)

        wordRef.updateData(data) { error in
            if let error = error {
                self.delegate?.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                self.word = word
                self.hideAllButtons(true)
                self.delegate?.showAlert(title: "Success", message: "Word has been updated")
            }
            self.loader.isHidden = true
            self.isImageSet = false
        }
    }
}
