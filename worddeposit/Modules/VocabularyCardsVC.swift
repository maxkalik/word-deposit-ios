import UIKit

protocol VocabularyCardsVCDelegate: VocabularyTVC {
    func wordCardDidUpdate(word: Word, index: Int)
}

class VocabularyCardsVC: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var wordsCollectionView: UICollectionView! {
        didSet {
            wordsCollectionView.delegate = self
            wordsCollectionView.dataSource = self
            wordsCollectionView.isPrefetchingEnabled = false
            // I turned off default adjustment wich solves the problem collectionView presenting popover.
            wordsCollectionView.contentInsetAdjustmentBehavior = .never
            if let flowLayout = wordsCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.minimumLineSpacing = 0
                flowLayout.minimumInteritemSpacing = 0
                flowLayout.scrollDirection = .horizontal
            }
        }
    }
    
    // MARK: - Instances
    
    var words = [Word]()
    var wordIndexPath: Int = 0
    var lastIndexPath: Int = 0
    
    weak var delegate: VocabularyCardsVCDelegate?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWordsCollectionView()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidLayoutSubviews() {
        // this should be checked because it is called by multiple times if try to drag the view
        if wordIndexPath != lastIndexPath {
            lastIndexPath = wordIndexPath
            let indexPath = IndexPath(item: self.wordIndexPath, section: 0)
            self.wordsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    // MARK: - Supporting Methods
    
    private func setupWordsCollectionView() {
        let nib = UINib(nibName: XIBs.VocabularyCardCVCell, bundle: nil)
        wordsCollectionView.register(nib, forCellWithReuseIdentifier: XIBs.VocabularyCardCVCell)
    }
}

// MARK: - Setting up UICollecitonView

extension VocabularyCardsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = wordsCollectionView.dequeueReusableCell(withReuseIdentifier: XIBs.VocabularyCardCVCell, for: indexPath) as? VocabularyCardCVCell {
            // here was an fatal error - out of range
            cell.configureCell(word: words[indexPath.item], index: indexPath.item, delegate: self)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.frame.size
    }
}

// MARK: - VocabularyCardCVCellDelegate

extension VocabularyCardsVC: VocabularyCardCVCellDelegate {
    func showAlert(title: String, message: String) {
        self.simpleAlert(title: title, msg: message)
    }
    
    typealias Handler = ((UIAlertAction) -> Void)?
    func showFullAlert(title: String, message: String, okTitle: String, cancelTitle: String, okHandler: Handler = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okTitle, style: .default, handler: okHandler))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func presentVC(_ viewControllerToPresent: UIViewController) {
        present(viewControllerToPresent, animated: true, completion: nil)
    }
    
    func disableEnableScroll(isKeyboardShow: Bool) {
        wordsCollectionView.isScrollEnabled = !isKeyboardShow
    }
    
    func wordDidUpdate(word: Word, index: Int) {
        words[index] = word
        delegate?.wordCardDidUpdate(word: word, index: index)
    }
}
