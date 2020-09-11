import UIKit
import Firebase
import FirebaseFirestore

private let reuseIdentifier = XIBs.PracticeCVCell
private let minWordsAmount = 10

class PracticeCVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIPopoverPresentationControllerDelegate {

    // MARK: - Instances

    var words = [Word]()
    private var trainers = [PracticeTrainer]()
    
    var practiceReadVC: PracticeReadVC?
    var progressHUD = ProgressHUD(title: "Welcome")
    var messageView = MessageView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        trainers = PracticeTrainers().data
        registerViews()
        setupUI()

        let userService = UserService.shared
        userService.fetchCurrentUser { user in
            userService.fetchVocabularies { vocabularies in
                if vocabularies.isEmpty {
                    self.presentVocabulariesVC()
                } else {
                    userService.getCurrentVocabulary()
                    self.fetchWords()
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(vocabularyDidSwitch), name: Notification.Name(rawValue: vocabulariesSwitchNotificationKey), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageView.frame.origin.y = collectionView.contentOffset.y
    }
    
    // MARK: - User Service Methods
    
    func fetchWords() {
        UserService.shared.fetchWords { words in
            self.words.removeAll()
            self.progressHUD.hide()
            self.words = words
            self.setupContent()
        }
    }
    
    @objc func vocabularyDidSwitch() {
        self.words.removeAll()
        self.words = UserService.shared.words
        setupContent()
    }
    
    // MARK: - Setup Views
    
    private func setupContent() {
        if words.count < minWordsAmount {
            self.setupMessage(wordsCount: words.count)
            self.messageView.show()
        } else {
            self.messageView.hide()
        }
        
        self.collectionView.reloadData()
        self.collectionView.isHidden = false
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
        messageView.setTitles(messageTxt: "You have insufficient words amount for practice.\nAdd at least \(minWordsAmount - wordsCount) words", buttonTitle: "Add more words")
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
                
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
                self.navigationController?.navigationBar.shadowImage = UIImage()
                self.navigationController?.navigationBar.isTranslucent = true
                self.navigationController?.view.backgroundColor = .clear
                
                let backItem = UIBarButtonItem()
                backItem.title = ""
                self.navigationItem.backBarButtonItem = backItem
                self.navigationController?.navigationBar.tintColor = UIColor.white
                
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
        UserService.shared.updateAnswersScore(words) {
            self.words = UserService.shared.words
        }
    }
}
