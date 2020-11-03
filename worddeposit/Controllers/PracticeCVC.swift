import UIKit

private let reuseIdentifier = XIBs.PracticeCVCell
private let minWordsAmount = 10


class PracticeCVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIPopoverPresentationControllerDelegate {

    // MARK: - Instances

    var words = [Word]()
    private var trainers = [PracticeTrainer]()
    
    var practiceReadVC: PracticeReadVC?
    var progressHUD = ProgressHUD(title: "Fetching...")
    var messageView = MessageView()
    var rightBarItem = TopBarItem()
    
    private var isVocabularySwitched = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trainers = PracticeTrainers().data
        registerViews()
        setupUI()
        
        disableInteractingWithUI()
        
        if UserService.shared.user != nil {
            fetchData()
        } else {
            UserService.shared.fetchCurrentUser { error, user in
                if let error = error {
                    self.simpleAlert(title: "Error", msg: error.localizedDescription)
                    PresentVC.loginVC(from: self.view)
                    return
                } else {
                    guard let _ = user else {
                        PresentVC.loginVC(from: self.view)
                        return
                    }
                    self.fetchData()
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(vocabularyDidSwitch), name: Notification.Name(rawValue: Keys.vocabulariesSwitchNotificationKey), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        messageView.frame.origin.y = collectionView.contentOffset.y
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // show tab bar after finishing practice
        guard let tabBarController = tabBarController else { return }
        if tabBarController.tabBar.isHidden {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                tabBarController.tabBar.alpha = 0
                tabBarController.tabBar.isHidden = false
                self.navigationController?.setup(isClear: true)
                UIView.animate(withDuration: 0.3) { [self] in
                    tabBarController.tabBar.alpha = 1
                    view.layoutIfNeeded()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserService.shared.vocabulary != nil && !isVocabularySwitched {
            setupContent(words: UserService.shared.words)
        }
    }
    
    // MARK: - User Service Methods
    
    @objc func vocabularyDidSwitch() {
        isVocabularySwitched = true
        setupContent(words: UserService.shared.words)
    }
    
    // MARK: - Setup Views
    
    private func fetchData() {
        UserService.shared.fetchVocabularies { error, vocabularies in
            if let error = error {
                UserService.shared.db.handleFirestoreError(error, viewController: self)
                self.progressHUD.hide()
                return
            }
            guard let vocabularies = vocabularies else { return }
            if vocabularies.isEmpty {
                self.presentVocabulariesVC()
                self.allowInteractingWithUI()
                self.progressHUD.hide()
            } else {
                UserService.shared.getCurrentVocabulary()
                UserService.shared.fetchWords { error, words  in
                    if let error = error {
                        UserService.shared.db.handleFirestoreError(error, viewController: self)
                        self.progressHUD.hide()
                        return
                    }
                    guard let words = words else { return }
                    self.progressHUD.hide()
                    self.allowInteractingWithUI()
                    self.setupContent(words: words)
                }
            }
        }
    }
    
    private func allowInteractingWithUI() {
        navigationController?.navigationBar.isUserInteractionEnabled = true
        tabBarController?.tabBar.isUserInteractionEnabled = true
    }
    
    private func disableInteractingWithUI() {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        tabBarController?.tabBar.isUserInteractionEnabled = false
    }
    
    private func setupContent(words: [Word]) {
        self.words.removeAll()
        self.words = words
        
        if words.count < minWordsAmount {
            setupMessage(wordsCount: words.count)
            messageView.show()
        } else {
            messageView.hide()
        }
        
        collectionView.reloadData()
        collectionView.isHidden = false
        isVocabularySwitched = false
    }
    
    private func setupUI() {
        
        // background
        collectionView.backgroundView?.backgroundColor = Colors.silver
        collectionView.backgroundColor = Colors.silver
        
        // setup loading view
        self.view.addSubview(progressHUD)
        progressHUD.show()
        
        // setup collection view
        setupCollectionView()
        
        // setup message view
        collectionView.addSubview(messageView)
        messageView.hide()
        setupMessage(wordsCount: words.count)
        setupNavigationBar()
    }
    
    private func setupMessage(wordsCount: Int) {
        messageView.setTitles(messageTxt: "You have insufficient words amount for practice.", buttonTitle: "Add at least \(minWordsAmount - wordsCount) words")
        messageView.onPrimaryButtonTap { PresentVC.addWordVC(from: self) }
    }
    
    private func registerViews() {
        // Register cell classes
        let nib = UINib(nibName: XIBs.PracticeCVCell, bundle: nil)
        collectionView!.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: ReusableIdentifiers.MessageView)
    }
    
    private func setupCollectionView() {
        if let flowlayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowlayout.minimumLineSpacing = 20
        }
        collectionView!.isPrefetchingEnabled = false
    }
    
    private func presentVocabulariesVC() {
        let storyboard = UIStoryboard(name: Storyboards.Home, bundle: .main)
        let vc = storyboard.instantiateViewController(withIdentifier: Controllers.Vocabularies)
        vc.modalPresentationStyle = .popover
        if let popoverPresentationController = vc.popoverPresentationController {
            popoverPresentationController.delegate = self
        }
        self.present(vc, animated: true)
    }
    
    // MARK: - Tests
    
    private func setupNavigationBar() {
        // Right Bar Button Item
        rightBarItem.setIcon(name: Icons.Profile)
        rightBarItem.circled()
        rightBarItem.onPress {
            self.performSegue(withIdentifier: Segues.Profile, sender: self)
        }
        let rightBarButtonItem = UIBarButtonItem(customView: rightBarItem)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    // MARK: - IBActions
    
    @IBAction func vocabulariesBarButtonPressed(_ sender: Any) {
        print("vocabularies tapped")
    }
    
    // MARK: - UICollectinView Delegates

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trainers.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PracticeCVCell {
            let trainer = trainers[indexPath.row]
            cell.backgroundColor = trainer.backgroundColor
            cell.configureCell(cover: trainer.coverImageSource, title: trainer.title)
            return cell
        }
        
        return PracticeCVCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        return CGSize(width: screenSize.width - 40, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sender = trainers[indexPath.row]
        self.performSegue(withIdentifier: Segues.PracticeRead, sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.PracticeRead {
            self.practiceReadVC = segue.destination as? PracticeReadVC

            if let sender = (sender as? PracticeTrainer) {
                
                tabBarController?.tabBar.isHidden = true

                // Restore the tabbar when it's popped in the future
                navigationController?.setup(isClear: true)
                
                practiceReadVC?.delegate = self

                // worddesk
                updatePracticeVC()
                
                switch sender.controller {
                case Controllers.TrainerWordToTranslate:
                    practiceReadVC?.view.backgroundColor = .purple
                    practiceReadVC?.practiceType = Controllers.TrainerWordToTranslate
                case Controllers.TrainerTranslateToWord:
                    practiceReadVC?.view.backgroundColor = .blue
                    practiceReadVC?.practiceType = Controllers.TrainerTranslateToWord
                default:
                    break
                }
            }
        }
    }
}

extension PracticeCVC: PracticeReadVCDelegate {
    
    func updatePracticeVC() {
        let wordsDesk = makeWordDesk(size: 5, wordsData: words)
        practiceReadVC?.wordsDesk = wordsDesk
    }
    
    func onFinishTrainer(with words: [Word]) {
        UserService.shared.updateAnswersScore(words) { error in
            if error != nil {
                self.simpleAlert(title: "Error", msg: "Cannot update answers score")
                return
            }
            self.words = UserService.shared.words
        }
    }
}
