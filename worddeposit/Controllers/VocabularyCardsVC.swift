import UIKit

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
    
    var vocabularyId: String!
    var words = [Word]()
    var wordIndexPath: Int = 0
    var lastIndexPath: Int = 0
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWordsCollectionView()
        
        let defaults = UserDefaults.standard
        guard let vocabularyId = defaults.string(forKey: "vocabulary_id") else { return }
        self.vocabularyId = vocabularyId
        print("vocabulary id from card", vocabularyId)
        
        
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
            cell.configureCell(vocabularyId: self.vocabularyId, word: words[indexPath.item], delegate: self)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.safeAreaLayoutGuide.layoutFrame.size.height)
    }
}

// MARK: - VocabularyCardCVCellDelegate

extension VocabularyCardsVC: VocabularyCardCVCellDelegate {
    func showAlert(title: String, message: String) {
        self.simpleAlert(title: title, msg: message)
    }
    
    func presentVC(_ viewControllerToPresent: UIViewController) {
        present(viewControllerToPresent, animated: true, completion: nil)
    }
    
    func disableEnableScroll(isKeyboardShow: Bool) {
        wordsCollectionView.isScrollEnabled = !isKeyboardShow
    }
}
