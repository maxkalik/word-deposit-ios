import UIKit
import Kingfisher
import YPImagePicker

protocol VocabularyCardCVCellDelegate: VocabularyCardsVC {
    func showAlert(title: String, message: String)
    func presentVC(_ viewControllerToPresent: UIViewController)
    func disableEnableScroll(isKeyboardShow: Bool)
    func wordDidUpdate(word: Word, index: Int)
}

class VocabularyCardCVCell: UICollectionViewCell, WordTextViewDelegate {

    // MARK: - Outlets

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentInsetAdjustmentBehavior = .never
            scrollView.delegate = self
        }
    }
    @IBOutlet weak var wordImageButton: UIButton! {
        didSet {
            wordImageButton.imageView?.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var wordExampleTextView: PrimaryTextView!
    @IBOutlet weak var wordTranslationTextView: TranslationTextView!
    @IBOutlet weak var wordDescriptionTextView: DescriptionTextView!

    @IBOutlet weak var saveChangingButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var pictureLoader: UIActivityIndicatorView!
    @IBOutlet weak var removePictureButton: UIButton!

    // MARK: - Variables

    private var word: Word!
    private var indexItem: Int!
    private var isKeyboardShowing = false
    
    weak var delegate: VocabularyCardCVCellDelegate?
    
    private var progressHUD = ProgressHUD(title: "Saving")
    
    // MARK: - View Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setupUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        wordExampleTextView.actionsDelegate = self
        wordTranslationTextView.actionsDelegate = self
        wordDescriptionTextView.actionsDelegate = self
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // WordTextViewDelegate
    
    func editingChanged() {
        guard let wordExample = wordExampleTextView.text,
            let wordTranslation = wordTranslationTextView.text,
            let wordDescription = wordDescriptionTextView.text else { return }
        
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
    
    
    // MARK: - @objc methods
   
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if isKeyboardShowing { return }
        isKeyboardShowing = true
        if word.description.isEmpty {
            wordDescriptionTextView.isHidden = false
        }
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom + 20)
        scrollView.setContentOffset(bottomOffset, animated: true)
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight: CGFloat = keyboardFrame.cgRectValue.height
            showAllButtons()
            frame.origin.y -= keyboardHeight
        }
        UIView.animate(withDuration: 0.3) { [self] in
            wordImageButton.alpha = 0.2
            removePictureButton.alpha = 0
            removePictureButton.isEnabled = false
            if word.description.isEmpty {
                wordDescriptionTextView.alpha = 1
            }
        }
        delegate?.disableEnableScroll(isKeyboardShow: true)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if !isKeyboardShowing { return }
        isKeyboardShowing = false
        frame.origin.y = 0
        if !cancelButton.isEnabled && !saveChangingButton.isEnabled {
            hideAllButtons()
        }
        UIView.animate(withDuration: 0.3) { [self] in
            removePictureButton.alpha = 1
            removePictureButton.isEnabled = true
            
            if (word.description.isEmpty) {
                wordDescriptionTextView.hide()
            }
            wordImageButton.alpha = 1
        }
        delegate?.disableEnableScroll(isKeyboardShow: false)
    }
    
    // MARK: - Other methods
    
    private func setupUI() {
        wordImageButton.imageView?.layer.cornerRadius = Radiuses.large / 1.5
        scrollView.backgroundColor = Colors.silver
        removePictureButton.isHidden = true
        hideAllButtons()
        disableAllButtons()
        setupImagePlaceholder()
    }
    
    private func setupDescriptionTextView() {
        if word.description.isEmpty {
            wordDescriptionTextView.hide()
        } else {
            wordDescriptionTextView.show()
        }
    }
        
    private func setupImagePlaceholder() {
        wordImageButton.backgroundColor = Colors.lightGrey
        let image = UIImage(named: Icons.Picture)?.withRenderingMode(.alwaysTemplate)
        wordImageButton.setImage(image, for: .normal)
        wordImageButton.tintColor = Colors.silver
    }
    
    func configureCell(word: Word, index: Int, delegate: VocabularyCardCVCellDelegate) {
        self.word = word
        self.indexItem = index
        self.delegate = delegate
        setupWord(word)
        removePictureButton.isHidden = word.imgUrl.isEmpty
    }
    
    private func setupWord(_ word: Word) {
        if let url = URL(string: word.imgUrl) {
            wordImageButton.imageView?.kf.indicatorType = .activity
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
            let imgRecourse = ImageResource(downloadURL: url, cacheKey: word.imgUrl)
            wordImageButton.kf.setImage(with: imgRecourse, for: .normal, options: options)
            wordImageButton.backgroundColor = .clear
        }
        
        wordDescriptionTextView.isPlaceholderSet = false
        
        wordExampleTextView.text = word.example
        wordTranslationTextView.text = word.translation
        wordDescriptionTextView.text = word.description
        
        setupDescriptionTextView()
    }
    
    // MARK: - IBActions
    
    @IBAction func wordPictureButtonTouched(_ sender: UIButton) {
        let ypConfig = YPImagePickerConfig()
        let picker = YPImagePicker(configuration: ypConfig.defaultConfig())
        
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.wordImageButton.setImage(photo.image, for: .normal)
                self.uploadImage()
            }
            picker.dismiss(animated: true, completion: nil)
        }
        self.delegate?.presentVC(picker)
    }

    @IBAction func onSaveChangingTouched(_ sender: UIButton) {
        if progressHUD.superview == nil {
            contentView.addSubview(progressHUD)
        }
        
        progressHUD.show()
        uploadWord()
        disableAllButtons()
    }
    
    @IBAction func onCancelTouched(_ sender: UIButton) {
        setupWord(word)
        disableAllButtons()
        if !isKeyboardShowing {
            hideAllButtons()
        }
    }
    
    @IBAction func removePictureTouched(_ sender: UIButton) {
        delegate?.showFullAlert(title: "Remove this picture?", message: "", okTitle: "Yes", cancelTitle: "No", okHandler: { _ in
            self.pictureLoader.startAnimating()
            self.word.imgUrl = ""
            UserService.shared.removeWordImageFrom(wordId: self.word.id) {
                self.updateWordImageUrl(isRemove: true)
            }
        })
    }
    
    // MARK: - Uploading Methods
    
    private func dismissKeyboard() {
        hideAllButtons()
        isKeyboardShowing = false
        wordExampleTextView.resignFirstResponder()
        wordTranslationTextView.resignFirstResponder()
        wordDescriptionTextView.resignFirstResponder()
        endEditing(true)
    }
    
    private func updateWordImageUrl(isRemove: Bool) {
        UserService.shared.updateWordImageUrl(self.word) { error in
            if error != nil {
                self.delegate?.showAlert(title: "Error", message: "Something went wrong. Cannot update a picture")
                return
            }
            self.pictureLoader.stopAnimating()
            self.removePictureButton.isHidden = isRemove
            if isRemove {
                self.setupImagePlaceholder()
            }
            self.delegate?.wordDidUpdate(word: self.word, index: self.indexItem)
        }
    }
    
    private func uploadImage() {
        pictureLoader.startAnimating()
        guard let image = wordImageButton.imageView?.image else {
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
        
        guard let example = wordExampleTextView.text, example.isNotEmpty,
            let translation = wordTranslationTextView.text, translation.isNotEmpty
            else {
                self.delegate?.showAlert(title: "Error", message: "Fields cannot be empty")
                return
        }
        
        if UserService.shared.words.contains(where: { $0.example.lowercased() == example.lowercased() && $0.id != word.id && $0.translation.lowercased() == translation.lowercased() }) {
            self.delegate?.showAlert(title: "You have already this word", message: " \(example) is already exist. Try to make another one")
            progressHUD.hide()
            return
        }
        
        guard let description = wordDescriptionTextView.text else { return }
        
        // Making a copy of the word
        var updatedWord = word!
        updatedWord.example = example
        updatedWord.translation = translation
        if description.isNotEmpty {
            updatedWord.description = description
        }
        
        UserService.shared.updateWord(updatedWord) { error, _ in
            if error != nil {
                self.progressHUD.hide()
                self.delegate?.showAlert(title: "Error", message: "Something went wrong. Cannot update the word.")
                return
            }
            self.word = updatedWord
            
            self.progressHUD.success(with: "Added")
            self.dismissKeyboard()
            self.delegate?.wordDidUpdate(word: updatedWord, index: self.indexItem)
            
        }
    }
}

extension VocabularyCardCVCell {
    
    private func showAllButtons() {
        UIView.animate(withDuration: 0.3) { [self] in
            saveChangingButton.alpha = 1
            cancelButton.alpha = 1
        }
    }
    
    private func hideAllButtons() {
        UIView.animate(withDuration: 0.3) { [self] in
            saveChangingButton.alpha = 0
            cancelButton.alpha = 0
        }
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

extension VocabularyCardCVCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let transform = WordImageButtonHelper.shared.transformOnScroll(with: scrollView.contentOffset, and: wordImageButton.frame.size.height)
        wordImageButton.layer.transform = transform
    }
}
