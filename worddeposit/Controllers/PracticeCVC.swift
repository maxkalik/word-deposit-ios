import UIKit

private let reuseIdentifier = XIBs.PracticeCVCell
private let minWordsAmount = 10

class PracticeCVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIPopoverPresentationControllerDelegate {

    // MARK: - Instances

    var words = [Word]()
    private var trainers = [PracticeTrainer]()
    
    var practiceReadVC: PracticeReadVC?
    var progressHUD = ProgressHUD(title: "Welcome")
    var messageView = MessageView()
    
    var isVocabularySwitched = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        trainers = PracticeTrainers().data
        registerViews()
        setupUI()

        let userService = UserService.shared
        userService.fetchCurrentUser { error, user in
            if let error = error {
                self.simpleAlert(title: "Error", msg: error.localizedDescription)
                return
            }
            guard let _ = user else {
                self.simpleAlert(title: "Error", msg: "Cannot find a user")
                showLoginVC(view: self.view)
                return
            }
            userService.fetchVocabularies { error, vocabularies in
                if let error = error {
                    UserService.shared.db.handleFirestoreError(error, viewController: self)
                    self.progressHUD.hide()
                    return
                }
                guard let vocabularies = vocabularies else { return }
                if vocabularies.isEmpty {
                    self.presentVocabulariesVC()
                    self.progressHUD.hide()
                } else {
                    userService.getCurrentVocabulary()
                    userService.fetchWords { error, words  in
                        if let error = error {
                            userService.db.handleFirestoreError(error, viewController: self)
                            self.progressHUD.hide()
                            return
                        }
                        guard let words = words else { return }
                        self.progressHUD.hide()
                        self.setupContent(words: words)
                    }
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(vocabularyDidSwitch), name: Notification.Name(rawValue: Keys.vocabulariesSwitchNotificationKey), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        messageView.frame.origin.y = collectionView.contentOffset.y
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
    
    private func setupContent(words: [Word]) {
        self.words.removeAll()
        self.words = words
        
        print("-------")
        words.forEach { word in
            print(word.example)
        }
        
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
        
        // setup loading view
        self.view.addSubview(progressHUD)
        progressHUD.show()
        
        // setup collection view
        setupCollectionView()
        
        // setup message view
        collectionView.addSubview(messageView)
        messageView.hide()
        setupMessage(wordsCount: words.count)
    }
    
    private func setupMessage(wordsCount: Int) {
        messageView.setTitles(messageTxt: "You have insufficient words amount for practice.", buttonTitle: "Add at least \(minWordsAmount - wordsCount) words")
        // push to add word view
        messageView.onPrimaryButtonTap { self.tabBarController?.selectedIndex = 1 }
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
        view.backgroundColor = UIColor.systemBackground
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
    
    // MARK: -
    
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
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        
//        let backItem = UIBarButtonItem()
//        backItem.title = ""
//        navigationItem.backBarButtonItem = backItem
//        navigationController?.navigationBar.tintColor = UIColor.white
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sender = trainers[indexPath.row]
        self.performSegue(withIdentifier: Segues.PracticeRead, sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.PracticeRead {
            self.practiceReadVC = segue.destination as? PracticeReadVC
            if let sender = (sender as? PracticeTrainer) {
                
                // Hide the tabbar during this segue
                hidesBottomBarWhenPushed = true

                // Restore the tabbar when it's popped in the future
                DispatchQueue.main.async { self.hidesBottomBarWhenPushed = false }
                
                self.setupNavigationBar()
                
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
