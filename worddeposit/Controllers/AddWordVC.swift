import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore
import YPImagePicker

class AddWordVC: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var wordImagePickerBtn: UIButton!
    @IBOutlet weak var addWordButton: RoundedButton!
    @IBOutlet weak var clearAllButton: UIButton!
    @IBOutlet weak var wordExampleTextField: UITextField!
    @IBOutlet weak var wordTranslationTextField: UITextField!
    @IBOutlet weak var loader: RoundedView!
    
    // MARK: - Variables
    
    var db: Firestore!
    var storage: Storage!
    var wordRef: DocumentReference!
    var isImageSet = false
    
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        storage = Storage.storage()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        wordExampleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        wordTranslationTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    // MARK: - @objc Methods
    @objc func textFieldDidChange(_ textField: UITextField) {
        textFieldValidation()
    }
    
    // MARK: - Support Methods
    
    func textFieldValidation() {
        guard let wordExample = wordExampleTextField.text, let wordTranslation = wordTranslationTextField.text else { return }
        print(wordExample.isEmpty && wordTranslation.isEmpty, wordExample.isEmpty || wordTranslation.isEmpty)
        
        addWordButton.isHidden = wordExample.isEmpty || wordTranslation.isEmpty
        clearAllButton.isHidden = wordExample.isEmpty && wordTranslation.isEmpty
    }
    
    private func setupUI() {
        loader.isHidden = true
        wordImagePickerBtn.layer.cornerRadius = 8
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
