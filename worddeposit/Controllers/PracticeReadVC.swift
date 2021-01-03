import UIKit
import Kingfisher

protocol PracticeReadVCDelegate: AnyObject {
    func updatePracticeVC(except trainedWordIds: Set<String>?)
    func onFinishTrainer(with words: [Word])
}

class PracticeReadVC: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    // MARK: - Instances
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.contentInsetAdjustmentBehavior = .always
            
        }
    }
    
    let answerItemBubbleLabel = BubbleLabel()
    
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
    
    private var rightAnswerIds = Set<String>()
    private var sessionRightAnswersSum = 0 {
        didSet {
            guard let word = trainedWord else { return }
            if !rightAnswerIds.contains(word.id) { rightAnswerIds.insert(word.id) }
        }
    }
    private var sessionWrongAnswersSum = 0
    
    private let successMessage = SuccessMessageVC()
    
    weak var delegate: PracticeReadVCDelegate?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var wordImage: RoundedImageView! {
        didSet {
            wordImage.contentMode = .scaleAspectFill
        }
    }
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
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        collectionView.collectionViewLayout = layout
        
        practiceLabel.font = UIFont(name: Fonts.bold, size: 28)
        practiceLabel.lineBreakMode = .byWordWrapping
        practiceLabel.numberOfLines = 0
        
        setNavigationBarLeft()
        setNavgationBarRight()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        spinner.stopAnimating()
        setupTrainedWord()
        
        // answerItemLabel.alpha = 0
        // answerItemLabel.backgroundColor = Colors.dark.withAlphaComponent(0.9)
        // answerItemLabel.layer.cornerRadius = Radiuses.large
        // answerItemLabel.layer.masksToBounds = true
        // answerItemLabel.lineBreakMode = .byTruncatingTail
        // answerItemLabel.numberOfLines = 0
        // answerItemLabel.font = UIFont(name: Fonts.bold, size: 16)
        // answerItemLabel.textAlignment = .center
        // answerItemLabel.textColor = .white
        
        view.addSubview(answerItemBubbleLabel)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.tintColor = Colors.dark
    }

    private func setNavigationBarLeft() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
        let imageView = UIImageView(frame: CGRect(x: 14, y: 10, width: 24, height: 24))
        if let imgBackArrow = UIImage(named: "finish") {
            let plainImage = imgBackArrow.withRenderingMode(.alwaysOriginal)
            imageView.image = plainImage
        }
        view.addSubview(imageView)

        let backTap = UITapGestureRecognizer(target: self, action: #selector(backToMain))
        view.addGestureRecognizer(backTap)

        let leftBarButtonItem = UIBarButtonItem(customView: view)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    private func setNavgationBarRight() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 24, height: 24))
        if let imgQuestion = UIImage(named: "question") {
            let plainImage = imgQuestion.withRenderingMode(.alwaysOriginal)
            imageView.image = plainImage
        }
        view.addSubview(imageView)
        
        let skipTap = UITapGestureRecognizer(target: self, action: #selector(skip))
        view.addGestureRecognizer(skipTap)
        
        let rightBarButtonItem = UIBarButtonItem(customView: view)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    
    @objc private func backToMain() {
        if trainedWords.count == 0 {
            _ = navigationController?.popViewController(animated: true)
        } else {
            prepareForQuit(isEmptyVocabulary: false)
        }
    }
    
    // MARK: - Methods
    
    private func result(_ trainedWord: Word, answer: Bool) {
        if let i = trainedWords.firstIndex(where: { $0.id == trainedWord.id }) {
            if answer == true {
                sessionRightAnswersSum += 1
                trainedWords[i].rightAnswers += 1
            } else {
                sessionWrongAnswersSum += 1
                trainedWords[i].wrongAnswers += 1
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
            trainedWords.append(word)
        }
    }
    
    func prepareForQuit(isEmptyVocabulary: Bool) {
        successMessage.isVocabularyEmpty = isEmptyVocabulary
        successMessage.delegate = self
        successMessage.wordsAmount = trainedWords.count
        successMessage.answersCorrect = sessionRightAnswersSum
        successMessage.answersWrong = sessionWrongAnswersSum
        successMessage.modalTransitionStyle = .crossDissolve
        successMessage.modalPresentationStyle = .popover
        delegate?.onFinishTrainer(with: trainedWords)
        present(successMessage, animated: true, completion: nil)
    }
    
    private func setupCollectionView() {
        let nib = UINib(nibName: XIBs.PracticeAnswerItem, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: XIBs.PracticeAnswerItem)
    }
    
    private func setupTrainedWord() {
        let filteredWordDesk = wordsDesk.filter { !rightAnswerIds.contains($0.id) }
        trainedWord = filteredWordDesk.randomElement()
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
    
    private func updateScreen() {
        isSelected = true
        spinner.startAnimating()
        collectionView.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateUI()
            self.spinner.stopAnimating()
        }
        
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        
        let labelHeight = practiceLabel.bounds.size.height
        scrollView.contentSize.height = contentView.frame.size.height + labelHeight - 40
        print(practiceLabel.bounds.size.height, contentView.frame.size.height)
        
    }
    
    private func updateUI() {
        
        delegate?.updatePracticeVC(except: rightAnswerIds)
        selectedIndex = nil
        isSelected = false
        collectionView.isUserInteractionEnabled = true
        setupTrainedWord()
        
        
        
        collectionView.reloadData()
    }
    
    // MARK: - IBActions
    
    @objc func skip() {
        guard let index = wordsDesk.firstIndex(matching: trainedWord!) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? PracticeAnswerItem {
            DispatchQueue.main.async {
                cell.hintAnswer()
            }
        }
        result(trainedWord!, answer: false)
        updateScreen()
    }
    
}

extension PracticeReadVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private func usePracticeType(for cell: PracticeAnswerItem, at index: Int) {
        switch practiceType {
        case Controllers.TrainerWordToTranslate:
            cell.configureCell(word: wordsDesk[index].translation)
        case Controllers.TrainerTranslateToWord:
            cell.configureCell(word: wordsDesk[index].example)
        default:
            break
        }
    }
    
    private func setupPracticeCell(_ cell: PracticeAnswerItem, at index: Int) {
        if selectedIndex == index {
            if wordsDesk[selectedIndex!].id == trainedWord!.id {
                cell.correctAnswer()
                result(self.trainedWord!, answer: true)
            } else {
                cell.wrondAnswer()
                result(self.trainedWord!, answer: false)
            }
        } else {
            if isSelected { cell.withoutAnswer() }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wordsDesk.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: XIBs.PracticeAnswerItem, for: indexPath) as? PracticeAnswerItem {
            usePracticeType(for: cell, at: indexPath.row)
            setupPracticeCell(cell, at: indexPath.row)
            cell.delegate = self
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = selectedIndex == indexPath.row ? nil : indexPath.row
        updateScreen()
    }
}

// MARK: - SuccessMessageVCDelegate

extension PracticeReadVC: SuccessMessageVCDelegate {
    func onSuccessMessageButtonTap() {
        _ = navigationController?.popViewController(animated: true)
    }
}


extension PracticeReadVC: PracticeAnswerItemDelegate {
    func practiceAnswerItemBeganLongPressed(with cellFrame: CGRect, and word: String) {

        answerItemBubbleLabel.frame = CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: 42)
        answerItemBubbleLabel.center = view.center
        answerItemBubbleLabel.frame.origin.y = collectionView.frame.origin.y - scrollView.contentOffset.y + cellFrame.origin.y - 56
        answerItemBubbleLabel.text = word
        answerItemBubbleLabel.frame.size.height += word.height(withConstrainedWidth: collectionView.frame.size.width - answerItemBubbleLabel.padding.left - answerItemBubbleLabel.padding.right, font: UIFont(name: Fonts.bold, size: 16)!)
        
        answerItemBubbleLabel.onPress()
        
    }
    
    func practiceAnswerItemDidFinishLongPress() {
        answerItemBubbleLabel.onFinishPress()
    }
}

extension PracticeReadVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        
        if offset.y < 0.0 {
            wordImage.layer.transform = CATransform3DIdentity
        } else {
            let scaleFactor = 1 + (-1 * offset.y / (wordImage.frame.size.height / 2))
            var transform = CATransform3DTranslate(CATransform3DIdentity, 0, (offset.y), 0)
            
            if scaleFactor >= 0.5 {
                transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1)
                wordImage.layer.transform = transform
                wordImage.layer.cornerRadius = (Radiuses.large + offset.y / 2)
            }
        }
    }
}
