import UIKit

class PracticeReadVC: UIViewController {
    
    var practiceType: String?
    var trainedWord: Word!
    var wordsDesk = [Word]()

    var selectedIndex: Int?
    var isSelected = false
    
    @IBOutlet weak var practiceLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
            collectionView.layer.borderWidth = 1
            collectionView.allowsMultipleSelection = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        
        let layout = UICollectionViewCenterLayout()
        layout.estimatedItemSize = CGSize(width: layout.itemSize.width, height: 40)
        collectionView.collectionViewLayout = layout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(practiceType ?? "nil")
        if wordsDesk.isEmpty {
            print("BUG! word desk is empty")
        }
        guard let word = trainedWord else { return }
        practiceLabel.text = word.example
    }
    
    private func setupCollectionView() {
        let nib = UINib(nibName: XIBs.PracticeAnswerItem, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: XIBs.PracticeAnswerItem)
    }
    
//    @objc private func wordDeskTouched(sender : UIButton) {
//        print(wordsDesk[sender.tag])
//    }
}

extension PracticeReadVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wordsDesk.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: XIBs.PracticeAnswerItem, for: indexPath) as? PracticeAnswerItem {
            cell.configureCell(word: wordsDesk[indexPath.row])
            
            if selectedIndex == indexPath.row {
                cell.backgroundColor = UIColor.red
            } else {
                if isSelected {
                    cell.backgroundColor = UIColor.white
                    cell.alpha = 0.5
                    cell.contentView.alpha = 0.5
                    cell.isUserInteractionEnabled = false
                }
            }
            
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = selectedIndex == indexPath.row ? nil : indexPath.row
        isSelected = true
        collectionView.reloadData()
    }
}
