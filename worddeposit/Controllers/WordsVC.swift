import UIKit

class WordsVC: UIViewController, WordCollectionViewCellDelegate {
    
    // Outlets
//    @IBOutlet weak var wordsScrollView: UIScrollView!
    @IBOutlet weak var wordsCollectionView: UICollectionView!
    
    // Variables
    var words = [Word]()
    var wordIndexPath: Int = 0
    var lastIndexPath: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWordsCollectionView()
        print("view did load")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        wordsCollectionView.reloadData()
        print("view will appear")
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//
//        super.viewDidAppear(true)
//        DispatchQueue.main.async {
//            let indexPath = IndexPath(item: self.wordIndexPath, section: 0)
//            self.wordsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
//            print("stoped loading")
//        }
//    }
    
    override func viewDidLayoutSubviews() {
        // this should be checked because it is called by multiple times if try to drag the view
        print("wordIndexPath", wordIndexPath, "lastIndex", lastIndexPath)
        if wordIndexPath != lastIndexPath {
            lastIndexPath = wordIndexPath
            let indexPath = IndexPath(item: self.wordIndexPath, section: 0)
            self.wordsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
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
        return CGSize(width: view.frame.width, height: view.safeAreaLayoutGuide.layoutFrame.size.height)
    }
}

