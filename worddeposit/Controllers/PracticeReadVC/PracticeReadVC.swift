import UIKit
import Kingfisher

protocol PracticeReadVCDelegate: AnyObject {
    func updatePracticeVC(except trainedWordIds: Set<String>?)
    func onFinishTrainer(with words: [Word])
}

class PracticeReadVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }
    
    let answerItemBubbleLabel = BubbleLabel()
    
    var practiceType: String?
    
    var trainedWord: Word? {
        didSet {
            PracticeReadHelper.shared.setupImage(&wordImage, for: trainedWord)
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
    
    weak var delegate: PracticeReadVCDelegate?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var wordImage: RoundedImageView! {
        didSet {
            wordImage.contentMode = .scaleAspectFill
        }
    }
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var practiceLabel: UILabel!
    @IBOutlet weak var answersCollectionView: UICollectionView! {
        didSet {
            answersCollectionView.delegate = self
            answersCollectionView.dataSource = self
            answersCollectionView.allowsMultipleSelection = false
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnswersCollectionView()
        setupAnswersCollectionViewLayout()
        setupTrainedWord()
        
        setupPracticeLabel()
        setupPracticeLabelText()
        
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        setNavigationBarLeft()
        setNavgationBarRight()
    }
    
    func setupPracticeLabel() {
        practiceLabel.font = UIFont(name: Fonts.bold, size: 28)
        practiceLabel.lineBreakMode = .byWordWrapping
        practiceLabel.numberOfLines = 0
    }
    
    func setupAnswersCollectionViewLayout() {
        let layout = UICollectionViewCenterLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        answersCollectionView.collectionViewLayout = layout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        spinner.stopAnimating()
        setupTrainedWord()
        setupPracticeLabelText()
        view.addSubview(answerItemBubbleLabel)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.tintColor = Colors.dark
    }

    private func setNavigationBarLeft() {
        let leftBarButtonItem = PracticeReadHelper.shared.setupNavBarLeft { [weak self] in
            guard let self = self else { return }
            self.backToMain()
        }
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    private func setNavgationBarRight() {
        let rightBarButtonItem = PracticeReadHelper.shared.setupNavBarRight { [weak self] in
            guard let self = self else { return }
            self.skip()
        }
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    // MARK: - Methods
    
    private func backToMain() {
        if trainedWords.count == 0 {
            _ = navigationController?.popViewController(animated: true)
        } else {
            prepareForQuit()
        }
    }
    
    func skip() {
        guard let index = wordsDesk.firstIndex(matching: trainedWord!) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        if let cell = answersCollectionView.cellForItem(at: indexPath) as? PracticeAnswerItem {
            DispatchQueue.main.async {
                cell.hintAnswer()
            }
        }
        result(trainedWord!, answer: false)
        updateScreen()
    }
    
    
    private func result(_ trainedWord: Word, answer: Bool) {
        PracticeReadHelper.shared.getResult(trainedWord, &trainedWords, answer: answer, &sessionRightAnswersSum, &sessionWrongAnswersSum)
    }
    
    func prepareForQuit() {
        
        let successMessage = SuccessMessageVC()
        successMessage.delegate = self
        
        successMessage.result = Result(wordsAmount: trainedWords.count, answerCorrect: sessionRightAnswersSum, answerWrong: sessionWrongAnswersSum)
        
        delegate?.onFinishTrainer(with: trainedWords)
        present(successMessage, animated: true, completion: nil)
    }
    
    private func setupAnswersCollectionView() {
        let nib = UINib(nibName: XIBs.PracticeAnswerItem, bundle: nil)
        answersCollectionView.register(nib, forCellWithReuseIdentifier: XIBs.PracticeAnswerItem)
    }
    
    private func setupTrainedWord() {
        let filteredWordDesk = wordsDesk.filter { !rightAnswerIds.contains($0.id) }
        trainedWord = filteredWordDesk.randomElement()
    }
    
    private func setupPracticeLabelText() {
        guard let word = trainedWord else { return }
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
        answersCollectionView.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateUI()
            self.spinner.stopAnimating()
        }
        answersCollectionView.reloadData()
    }

    private func updateUI() {
        delegate?.updatePracticeVC(except: rightAnswerIds)
        
        selectedIndex = nil
        isSelected = false
        
        answersCollectionView.isUserInteractionEnabled = true
        
        setupTrainedWord()
        setupPracticeLabelText()
        
        answersCollectionView.reloadData()
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
    
    // TODO: move this logic to the cell
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
        let bubbleLabelParams = BubbleLabelParams(
            collectionViewFrame: answersCollectionView.frame,
            cellFrame: cellFrame,
            viewContentOffcetY: scrollView.contentOffset.y,
            text: word)
        answerItemBubbleLabel.onPress(with: bubbleLabelParams)
    }
    
    func practiceAnswerItemDidFinishLongPress() {
        answerItemBubbleLabel.onFinishPress()
    }
}

extension PracticeReadVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        PracticeReadHelper.shared.transofrmOnScroll(wordImage: &wordImage, with: scrollView.contentOffset)
    }
}
