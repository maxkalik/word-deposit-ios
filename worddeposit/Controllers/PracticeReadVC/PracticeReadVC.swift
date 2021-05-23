import UIKit
import Kingfisher

class PracticeReadVC: UIViewController {
    
    private let answerItemBubbleLabel = BubbleLabel()
    var model: PracticeReadViewModel?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }
    
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
        model?.delegate = self
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        spinner.stopAnimating()
        view.addSubview(answerItemBubbleLabel)
        setupContent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.tintColor = Colors.dark
    }
    
    // MARK: - General Methods
    
    func setupUI() {
        setupBackground()
        setupAnswersCollectionView()
        setupAnswersCollectionViewLayout()
        setupPracticeWordLabel()
        setupNavigationBar()
    }
    
    func setupBackground() {
        guard let model = self.model else { return }
        switch model.practiceType {
        case .readWordToTranslate:
            view.backgroundColor = Colors.purple
        case .readTranslateToWord:
            view.backgroundColor = Colors.darkBlue
        }
    }
    
    func setupNavigationBar() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        setNavigationBarLeft()
        setNavgationBarRight()
    }
    
    func setupPracticeWordLabel() {
        practiceLabel.font = UIFont(name: Fonts.bold, size: 28)
        practiceLabel.lineBreakMode = .byWordWrapping
        practiceLabel.numberOfLines = 0
    }
    
    func setupContent() {
        guard let model = self.model else { return }
        model.setupContent()
        updatePracticeWordLabel()
    }
    
    func updatePracticeWordLabel() {
        PracticeReadHelper.shared.setupImage(&wordImage, for: self.model?.trainedWord)
        self.practiceLabel.text = self.model?.trainedWordTitle
    }
    
    func setupAnswersCollectionViewLayout() {
        let layout = UICollectionViewCenterLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        answersCollectionView.collectionViewLayout = layout
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
        if let model = self.model, model.trainedWords.isEmpty {
            _ = navigationController?.popViewController(animated: true)
        } else {
            prepareForQuit()
        }
    }
    
    func skip() {
        guard let index = model?.getSkipedAnswerIndex() else { return }
        if let cell = answersCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? PracticeAnswerItem {
            DispatchQueue.main.async {
                cell.hintAnswer()
            }
        }
        updateScreen()
    }
    
    func prepareForQuit() {
        let result = model?.getGeneralResult()
        let successMessage = SuccessMessageVC()
        successMessage.delegate = self
        successMessage.result = result
        present(successMessage, animated: true, completion: nil)
    }
    
    private func setupAnswersCollectionView() {
        let nib = UINib(nibName: XIBs.PracticeAnswerItem, bundle: nil)
        answersCollectionView.register(nib, forCellWithReuseIdentifier: XIBs.PracticeAnswerItem)
    }
    
    private func updateScreen() {
        spinner.startAnimating()
        answersCollectionView.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.updateUI()
            self.model?.updateWordsDesk()
            self.updatePracticeWordLabel()
            self.spinner.stopAnimating()
        }
        answersCollectionView.reloadData()
    }

    private func updateUI() {
        answersCollectionView.isUserInteractionEnabled = true
        answersCollectionView.reloadData()
    }
}

extension PracticeReadVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let words = self.model?.wordsDesk else { return 0 }
        return words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: XIBs.PracticeAnswerItem, for: indexPath) as? PracticeAnswerItem,
           let model = self.model,
           let words = model.wordsDesk {
            cell.delegate = self
            cell.configureCell(
                word: words[indexPath.row],
                practiceType: model.practiceType,
                answer: model.getAnswer(from: indexPath.row)
            )
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        model?.updateAnswer(with: indexPath.row)
        updateScreen()
    }
}

// MARK: - SuccessMessageVCDelegate

extension PracticeReadVC: SuccessMessageVCDelegate {
    func onSuccessMessageButtonTap() {
        model?.finishPractice()
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

extension PracticeReadVC: PracticeReadViewModelDelegate {
    func showAlert(title: String, msg: String) {
        self.simpleAlert(title: title, msg: msg)
    }
    func showSuccess() {
        prepareForQuit()
    }
}
