import UIKit

protocol PracticeReadVCDelegate: AnyObject {
    func updatePracticeVC()
}

class PracticeReadVC: UIViewController {
    
    // MARK: - Instances
    
    var practiceType: String?
    var trainedWord: Word?
    var wordsDesk = [Word]()

    var selectedIndex: Int?
    var isSelected = false
    
    weak var delegate: PracticeReadVCDelegate?
    
    // MARK: - IBOutlets
    
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
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTrainedWord()
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
        setupTrainedWord()
    }
    
    // MARK: - Methods
    
    private func setupCollectionView() {
        let nib = UINib(nibName: XIBs.PracticeAnswerItem, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: XIBs.PracticeAnswerItem)
    }
    
    private func setupTrainedWord() {
        trainedWord = wordsDesk.randomElement()
        guard let word = trainedWord else { return }
        // setup ui
        switch practiceType {
        case Controllers.TrainerWordToTranslate:
            practiceLabel.text = word.example
        case Controllers.TrainerTranslateToWord:
            practiceLabel.text = word.translation
        default:
            break
        }
    }
}


extension PracticeReadVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wordsDesk.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: XIBs.PracticeAnswerItem, for: indexPath) as? PracticeAnswerItem {
            
            switch practiceType {
            case Controllers.TrainerWordToTranslate:
                cell.configureCell(word: wordsDesk[indexPath.row].translation)
            case Controllers.TrainerTranslateToWord:
                cell.configureCell(word: wordsDesk[indexPath.row].example)
            default:
                break
            }

            if selectedIndex == indexPath.row {
                if wordsDesk[selectedIndex!].id == trainedWord?.id {
                    cell.backgroundColor = UIColor.green
                } else {
                    cell.backgroundColor = UIColor.red
                }
            } else {
                if isSelected {
                    cell.backgroundColor = UIColor.white
                    cell.alpha = 0.5
                    cell.contentView.alpha = 0.5
                }
            }
            
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = selectedIndex == indexPath.row ? nil : indexPath.row
        isSelected = true
        collectionView.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.delegate?.updatePracticeVC()
            self.selectedIndex = nil
            self.isSelected = false
            self.collectionView.isUserInteractionEnabled = true
            self.setupTrainedWord()
            self.collectionView.reloadData()
        }
        self.collectionView.reloadData()
    }
}
