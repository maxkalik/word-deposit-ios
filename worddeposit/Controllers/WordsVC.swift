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
        self.view.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.view.layer.borderWidth = 1
        print("view did load collection view")
    }
    
    override func viewLayoutMarginsDidChange() {
        print("margin changed")
    }
    
    override func viewDidLayoutSubviews() {
        
        // this should be checked because it is called by multiple times if try to drag the view
        print("view did layout subviews")
        super.viewDidLayoutSubviews()
        let indexPath = IndexPath(item: wordIndexPath, section: 0)
        self.wordsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
    
    func showAlert(title: String, message: String) {
        self.simpleAlert(title: title, msg: message)
    }
    
    func presentVC(_ viewControllerToPresent: UIViewController) {
        present(viewControllerToPresent, animated: true, completion: nil)
    }
    
    private func setupWordsCollectionView() {
        wordsCollectionView.delegate = self
        wordsCollectionView.dataSource = self
        
        let nib = UINib(nibName: Identifiers.WordCollectionViewCell, bundle: nil)
        wordsCollectionView.register(nib, forCellWithReuseIdentifier: Identifiers.WordCollectionViewCell)
        
        if let flowLayout = wordsCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
//            flowLayout.shouldInvalidateLayout(forBoundsChange: <#T##CGRect#>)
//            flowLayout.itemSize = self.wordsCollectionView.frame.size
//            flowLayout.itemSize = CGSize(width: view.frame.width - 200, height: view.frame.height)
        }
    }
}


extension WordsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = wordsCollectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.WordCollectionViewCell, for: indexPath) as? WordCollectionViewCell {
            cell.configureCell(word: words[indexPath.item], delegate: self)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: view.frame.width, height: view.safeAreaLayoutGuide.layoutFrame.size.height)
        return CGSize(width: view.frame.width, height: view.frame.height - 100)
    }
}

