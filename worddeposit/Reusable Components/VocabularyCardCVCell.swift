import UIKit
import Kingfisher
import YPImagePicker

protocol VocabularyCardCVCellDelegate: VocabularyCardsVC {
    func showAlert(title: String, message: String)
    func presentVC(_ viewControllerToPresent: UIViewController)
    func disableEnableScroll(isKeyboardShow: Bool)
    func wordDidUpdate(word: Word, index: Int)
}

class VocabularyCardCVCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var wordPictureButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var wordExampleTextField: UITextField!
    @IBOutlet weak var wordTranslationTextField: UITextField!
    @IBOutlet weak var wordDescriptionTextField: UITextField!
    @IBOutlet weak var saveChangingButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var wordLoader: UIActivityIndicatorView!
    @IBOutlet weak var pictureLoader: UIActivityIndicatorView!
    @IBOutlet weak var removePictureButton: UIButton!
    
    // MARK: - Variables

    private var word: Word!
    private var indexItem: Int!
    private var isKeyboardShowing = false
    
    weak var delegate: VocabularyCardCVCellDelegate?
    
    // MARK: - View Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        wordPictureButton.setImage(UIImage(named: Placeholders.Logo), for: .normal)
        
        hideAllButtons()
        disableAllButtons()
        
        removePictureButton.isHidden = true
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        hideAllButtons()
        disableAllButtons()
        
        wordExampleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        wordTranslationTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        wordDescriptionTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let nc = NotificationCenter.default

        nc.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        wordExampleTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        wordTranslationTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        wordDescriptionTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    // MARK: - @objc methods
    
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
            self.wordPictureButton.alpha = 0
        }
        
        delegate?.disableEnableScroll(isKeyboardShow: true)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        
        if !isKeyboardShowing { return }
        isKeyboardShowing = false
        frame.origin.y = 0
        hideAllButtons()
        
        UIView.animate(withDuration: 0.3) {
            self.wordPictureButton.alpha = 1
        }
        
        delegate?.disableEnableScroll(isKeyboardShow: false)
    }
    
    // MARK: - Other methods
    
    func configureCell(word: Word, index: Int, delegate: VocabularyCardCVCellDelegate) {
        self.word = word
        self.indexItem = index
        self.delegate = delegate
        setupWord(word)
        removePictureButton.isHidden = word.imgUrl.isEmpty
    }
    
    private func textFieldValidation() {
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
    
    private func setupWord(_ word: Word) {
        if let url = URL(string: word.imgUrl) {
            wordPictureButton.imageView?.kf.indicatorType = .activity
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
            let imgRecourse = ImageResource(downloadURL: url, cacheKey: word.imgUrl)
            wordPictureButton.kf.setImage(with: imgRecourse, for: .normal, options: options)
        }
        wordExampleTextField.text = word.example
        wordTranslationTextField.text = word.translation
        wordDescriptionTextField.text = word.description
    }
    
    // MARK: - IBActions
    
    @IBAction func wordPictureButtonTouched(_ sender: UIButton) {
        let ypConfig = YPImagePickerConfig()
        let picker = YPImagePicker(configuration: ypConfig.defaultConfig())
        
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.wordPictureButton.setImage(photo.image, for: .normal)
                self.uploadImage()
            }
            picker.dismiss(animated: true, completion: nil)
        }
        self.delegate?.presentVC(picker)
    }

    @IBAction func onSaveChangingTouched(_ sender: UIButton) {
        wordLoader.startAnimating()
        uploadWord()
        disableAllButtons()
    }
    
    @IBAction func onCancelTouched(_ sender: UIButton) {
        self.setupWord(word)
        disableAllButtons()
    }
    
    @IBAction func removePictureTouched(_ sender: UIButton) {
        pictureLoader.startAnimating()
        self.word.imgUrl = ""
        UserService.shared.removeWordImageFrom(wordId: word.id) {
            self.updateWordImageUrl(isRemove: true)
        }
    }
    
    // MARK: - Uploading Methods
    
    private func updateWordImageUrl(isRemove: Bool) {
           UserService.shared.updateWordImageUrl(self.word) { error in
               if error != nil {
                   self.delegate?.showAlert(title: "Error", message: "Something went wrong. Cannot update a picture")
                   return
               }
               self.pictureLoader.stopAnimating()
               self.removePictureButton.isHidden = isRemove
               if isRemove {
                   self.wordPictureButton.setImage(UIImage(named: Placeholders.Logo), for: .normal)
               }
               self.delegate?.wordDidUpdate(word: self.word, index: self.indexItem)
           }
       }
    
    private func uploadImage() {
        pictureLoader.startAnimating()
        guard let image = wordPictureButton.imageView?.image else {
            self.delegate?.showAlert(title: "Error", message: "Cannot upload your picture, Something went wrong")
            pictureLoader.stopAnimating()
            return
        }
        
        // remove previous image before uploading is an object have it
        if word.imgUrl.isNotEmpty {
            UserService.shared.removeWordImageFrom(wordId: word.id)
        }
        
        let resizedImg = image.resized(toWidth: 400.0)
        guard let data = resizedImg?.jpegData(compressionQuality: 0.5) else { return }
        
        UserService.shared.setWordImage(data: data, id: word.id) { error, url in
            if let error = error {
                self.delegate?.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            guard let url = url else { return }
            self.word.imgUrl = url.absoluteString
            self.updateWordImageUrl(isRemove: false)
        }
    }
    
    private func uploadWord() {
        
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
        
        UserService.shared.updateWord(updatedWord) { error, _ in
            if error != nil {
                self.delegate?.showAlert(title: "Error", message: "Something went wrong. Cannot update the word.")
                return
            }
            self.word = updatedWord
            self.wordLoader.stopAnimating()
            self.hideAllButtons()
            self.endEditing(true)
            self.delegate?.wordDidUpdate(word: updatedWord, index: self.indexItem)
            self.delegate?.showAlert(title: "Success", message: "Word has been updated")
        }
    }
}

extension VocabularyCardCVCell {
    private func hideAllButtons() {
        saveChangingButton.isHidden = true
        cancelButton.isHidden = true
    }
    
    private func showAllButtons() {
        saveChangingButton.isHidden = false
        cancelButton.isHidden = false
    }
    
    private func enableAllButtons() {
        cancelButton.isEnabled = true
        saveChangingButton.isEnabled = true
    }
    
    private func disableAllButtons() {
        cancelButton.isEnabled = false
        saveChangingButton.isEnabled = false
    }
}
