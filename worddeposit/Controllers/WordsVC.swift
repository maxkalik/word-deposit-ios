import UIKit

class WordsVC: UIViewController, WordCollectionViewCellDelegate {
    
    // Outlets
//    @IBOutlet weak var wordsScrollView: UIScrollView!
    @IBOutlet weak var wordsCollectionView: UICollectionView!
    
    // Variables
    var words = [Word]()
    var wordIndexPath: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWordsCollectionView()
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
    
    func showAlert(title: String, message: String) {
        print("Alert from delegation", title, message)
    }
    
    private func setupWordsCollectionView() {
        wordsCollectionView.delegate = self
        wordsCollectionView.dataSource = self
        let nib = UINib(nibName: Identifiers.WordCollectionViewCell, bundle: nil)
        wordsCollectionView.register(nib, forCellWithReuseIdentifier: Identifiers.WordCollectionViewCell)
        
        if let flowLayout = wordsCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 0
            flowLayout.itemSize = self.wordsCollectionView.frame.size
        }
    }
}


extension WordsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = wordsCollectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.WordCollectionViewCell, for: indexPath) as? WordCollectionViewCell {
            cell.configureCell(word: words[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 40)
    }
    
}
