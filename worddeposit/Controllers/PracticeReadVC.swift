import UIKit
import Kingfisher

protocol PracticeReadVCDelegate: AnyObject {
    func updatePracticeVC()
    func onFinishTrainer(with words: [Word])
}

class PracticeReadVC: UIViewController {
    
    // MARK: - Instances
    
    var practiceType: String?
    var trainedWord: Word? {
        didSet {
            guard let word = trainedWord else { return }
            if let url = URL(string: word.imgUrl) {
                wordImage.isHidden = false
                wordImage.kf.indicatorType = .activity
                let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
                let imgRecourse = ImageResource(downloadURL: url, cacheKey: word.imgUrl)
                wordImage.kf.setImage(with: imgRecourse, options: options)
            } else {
                wordImage.isHidden = true
            }
        }
    }
    var wordsDesk = [Word]()
    
    private var trainedWords = [Word]()
    private var selectedIndex: Int?
    private var isSelected = false
    
    private var sessionRightAnswersSum = 0
    private var sessionWrongAnswersSum = 0
    
    weak var delegate: PracticeReadVCDelegate?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var wordImage: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var practiceLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
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
        
        // back button preparing for action
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "🏁", style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func backAction() {
        if trainedWords.count == 0 {
            _ = navigationController?.popViewController(animated: true)
        } else {
            prepareForQuit()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        spinner.stopAnimating()
        setupTrainedWord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.tintColor = UIColor.systemBlue
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    // MARK: - Methods
    
    private func result(_ trainedWord: Word, answer: Bool) {
        if let i = trainedWords.firstIndex(where: { $0.id == trainedWord.id }) {
            if answer == true {
                sessionRightAnswersSum += 1
                self.trainedWords[i].rightAnswers += 1
            } else {
                sessionWrongAnswersSum += 1
                self.trainedWords[i].wrongAnswers += 1
            }
        } else {
            var word = trainedWord
            if answer == true {
                sessionRightAnswersSum += 1
                word.rightAnswers += 1
            } else {
                sessionWrongAnswersSum += 1
                word.wrongAnswers += 1
            }
            self.trainedWords.append(word)
        }
    }
    
    private func prepareForQuit() {
        print(trainedWords)
        print(trainedWords.count)
        print("right: \(sessionRightAnswersSum), wrong: \(sessionWrongAnswersSum)")
        
        let successMessage = SuccessMessageVC()
        successMessage.delegate = self
        
        successMessage.titleTxt = "Great!"
        successMessage.descriptionTxt = "You trained \(trainedWords.count) words\n Correct: \(sessionRightAnswersSum) / Wrong: \(sessionWrongAnswersSum)"
        
        successMessage.modalTransitionStyle = .crossDissolve
        successMessage.modalPresentationStyle = .popover
        
        self.delegate?.onFinishTrainer(with: trainedWords)
        present(successMessage, animated: true, completion: nil)
    }
    
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
    
    private func updateUI() {
        self.delegate?.updatePracticeVC()
        self.selectedIndex = nil
        self.isSelected = false
        self.collectionView.isUserInteractionEnabled = true
        self.setupTrainedWord()
        self.collectionView.reloadData()
    }
    
    // MARK: - IBActions
    
    @IBAction func skip(_ sender: UIBarButtonItem) {
        result(trainedWord!, answer: false)
        updateUI()
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
                if wordsDesk[selectedIndex!].id == trainedWord!.id {
                    cell.backgroundColor = UIColor.green
                    result(self.trainedWord!, answer: true)
                } else {
                    cell.backgroundColor = UIColor.red
                    result(self.trainedWord!, answer: false)
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
        spinner.startAnimating()
        collectionView.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // TODO: - check main queue
            self.updateUI()
            self.spinner.stopAnimating()
        }
        self.collectionView.reloadData()
    }
}

// MARK: - SuccessMessageVCDelegate

extension PracticeReadVC: SuccessMessageVCDelegate {
    func onSuccessMessageButtonTap() {
        _ = navigationController?.popViewController(animated: true)
    }
}
