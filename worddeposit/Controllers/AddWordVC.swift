import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore
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
    
    @IBOutlet weak var wordImagePickerBtn: UIButton! {
        didSet {
            wordImagePickerBtn.imageView?.contentMode = .scaleAspectFill
        }
        
    }
    
    @IBOutlet weak var addWordButton: RoundedButton!
    @IBOutlet weak var clearAllButton: UIButton!
    @IBOutlet weak var wordExampleTextField: UITextField!
    @IBOutlet weak var wordTranslationTextField: UITextField!
    @IBOutlet weak var loader: RoundedView!
    
    // MARK: - Instances
    
    var db: Firestore!
    var storage: Storage!
    var wordRef: DocumentReference!
    var isImageSet = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        storage = Storage.storage()

        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        wordExampleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        wordTranslationTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        wordExampleTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        wordTranslationTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    // MARK: - @objc Methods
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        textFieldValidation()
    }
    
    // MARK: - Support Methods
    
    func textFieldValidation() {
        guard let wordExample = wordExampleTextField.text, let wordTranslation = wordTranslationTextField.text else { return }
        addWordButton.isHidden = wordExample.isEmpty || wordTranslation.isEmpty
        clearAllButton.isHidden = wordExample.isEmpty && wordTranslation.isEmpty
    }
    
    private func setupUI() {
        loader.isHidden = true
        wordExampleTextField.autocorrectionType = .no
        wordTranslationTextField.autocorrectionType = .no
        addWordButton.isHidden = true
        clearAllButton.isHidden = true
    }
    
    func prepareForUpload() {
        guard let example = wordExampleTextField.text, example.isNotEmpty,
            let translation = wordTranslationTextField.text, example.isNotEmpty else {
                simpleAlert(title: "Error", msg: "Fill all fields")
                loader.isHidden = true
                return
        }
        
        // TODO: shoud be rewrited in the singleton
        guard let user = Auth.auth().currentUser else { return }
        
        wordRef = db.collection("users").document(user.uid).collection("words").document()
        var word = Word.init(imgUrl: "", example: example, translation: translation, id: "", timestamp: Timestamp())
        word.id = wordRef.documentID
        
        if isImageSet {
            uploadImage(userId: user.uid, word: word)
        } else {
            uploadWord(word: word)
        }
    }
    
    func uploadImage(userId: String, word: Word) {
        guard let image = wordImagePickerBtn.imageView?.image else {
            simpleAlert(title: "Error", msg: "Fill all fields")
            loader.isHidden = true
            return
        }
        
        var word = word // convert let to var
        
        let resizedImg = image.resized(toWidth: 400.0)
        guard let imageData = resizedImg?.jpegData(compressionQuality: 0.5) else { return }
        
        let imageRef = Storage.storage().reference().child("/\(userId)/\(word.id).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        imageRef.putData(imageData, metadata: metadata) { (storageMetadata, error) in
            if let error = error {
                self.simpleAlert(title: "Error", msg: "Unable to upload image")
                debugPrint(error.localizedDescription)
                return
            }
            
            imageRef.downloadURL { (url, error) in
                if let error = error {
                    self.simpleAlert(title: "Error", msg: "Unable to upload image")
                    self.loader.isHidden = true
                    debugPrint(error.localizedDescription)
                    return
                }
                guard let url = url else { return }
                word.imgUrl = url.absoluteString
                self.uploadWord(word: word)
            }
        }
    }
    
    func uploadWord(word: Word) {
        let data = Word.modelToData(word: word)
        wordRef.setData(data, merge: true) { (error) in
            if let error = error {
                self.simpleAlert(title: "error", msg: error.localizedDescription)
                self.loader.isHidden = true
                return
            }
            // success message here
            self.updateUI()
            self.loader.isHidden = true
        }
    }
    
    func updateUI() {
        self.wordImagePickerBtn.setImage(UIImage(named: Placeholders.Logo), for: .normal)
        wordExampleTextField.text = ""
        wordTranslationTextField.text = ""
        isImageSet = false
        addWordButton.isHidden = true
        clearAllButton.isHidden = true
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
        loader.isHidden = false
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
