import UIKit
import Firebase
import FirebaseFirestore

private let reuseIdentifier = XIBs.PracticeCVCell
private let minWordsAmount = 10

class PracticeCVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIPopoverPresentationControllerDelegate {

    // MARK: - Instances
    
    var user = User()
    var testUser = User()
    
    var words = [Word]()
    private var trainers = [PracticeTrainer]()
    
    var practiceReadVC: PracticeReadVC?
    var progressHUD = ProgressHUD(title: "Welcome")
    var messageView = MessageView()
    
    /// Listeners
    var auth: Auth!
    var db: Firestore!
    var authHandle: AuthStateDidChangeListenerHandle?
    var vocabulariesListener: ListenerRegistration!
    
    /// References
    var wordsRef: CollectionReference!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        auth = Auth.auth()
        db = Firestore.firestore()
        trainers = PracticeTrainers().data
        registerViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        setCurrentUser()
        
        UserService.shared.fetchCurrentUser { user in
            UserService.shared.fetchVocabularies { vocabularies in
                print(vocabularies)
                UserService.shared.getCurrentVocabulary()
                guard let vocabularyId = UserService.shared.currentVocabularyId else { return }
                print(vocabularyId)
                UserService.shared.fetchWords { words in
                    print(words)
                }
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageView.frame.origin.y = collectionView.contentOffset.y
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        auth.removeStateDidChangeListener(authHandle!)
        vocabulariesListener.remove()
        collectionView.reloadData()
    }
    
    // MARK: - Setup Views
    
    private func setupUI() {
        self.view.addSubview(progressHUD)
        progressHUD.show()
        setupCollectionView()
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
    
    // MARK: - Listeners Methods
    
    private func setCurrentUser() {
        authHandle = auth.addStateDidChangeListener { (auth, user) in
            guard let currentUser = auth.currentUser else { return }
            let userRef = self.db.collection("users").document(currentUser.uid)
            userRef.getDocument { (document, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }
                if let document = document, document.exists {
                    guard let data = document.data() else { return }
                    self.user = User.init(data: data)
                    self.progressHUD.setTitle(title: "Fetching words")
                    
                    // user defaults
                    let defaults = UserDefaults.standard
                    defaults.set(self.user.nativeLanguage, forKey: "native_language")
                    defaults.set(self.user.notifications, forKey: "notifications")
                    defaults.set(Date(), forKey: "last_run")
                    
                    self.setVocabulariesListener(from: userRef)
                    
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    private func setVocabulariesListener(from: DocumentReference) {
        let vocabularyRef = from.collection("vocabularies")
        vocabulariesListener = vocabularyRef.whereField("is_selected", isEqualTo: true).addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                if querySnapshot!.documents.isEmpty {
                    let storyboard = UIStoryboard(name: "Home", bundle: Bundle.main)
                    let vc = storyboard.instantiateViewController(withIdentifier: "Vocabularies")
                    vc.modalPresentationStyle = .popover
                    if let popoverPresentationController = vc.popoverPresentationController {
                        popoverPresentationController.delegate = self
                    }
                    self.present(vc, animated: true)
                }
                
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let vocabulary = Vocabulary.init(data: data)
                    let defaults = UserDefaults.standard
                    defaults.set(vocabulary.id, forKey: "vocabulary_id")
                    
                    // fetch words from current vocabulary
                    print("From practices", vocabulary.id)
                    self.fetchWords(from: vocabularyRef.document(vocabulary.id))
                }
            }
        }
    }
    
    private func fetchWords(from: DocumentReference) {
        wordsRef = from.collection("words")
        
        wordsRef.getDocuments { (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            self.words.removeAll()
            self.progressHUD.hide()
            guard let documents = snapshot?.documents else { return }
            
            DispatchQueue.main.async {
                if documents.count < minWordsAmount {
                    self.setupMessage(wordsCount: documents.count)
                    self.messageView.show()
                } else {
                    self.messageView.hide()
                }
            }
            
            for document in documents {
                let data = document.data()
                let word = Word.init(data: data)
                self.words.append(word)
            }
            self.collectionView.reloadData()
            self.collectionView.isHidden = false
        }
    }
    
    // MARK: - Make Word Desk
    
    func makeWordDesk(size: Int, wordsData: [Word], _ result: [Word] = []) -> [Word] {
        var result = result
        if wordsData.count < 5 {
            return result
        }
        var tmpCount = size
        if tmpCount <= 0 {
            return result.shuffled()
        }
        let randomWord: Word = wordsData.randomElement() ?? wordsData[0]
        if !result.contains(where: { $0.id == randomWord.id }) {
            result.append(randomWord)
            tmpCount -= 1
        }
        return makeWordDesk(size: tmpCount, wordsData: wordsData, result)
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
        for word in words {
            wordsRef.document(word.id).updateData(["right_answers" : word.rightAnswers, "wrong_answers" : word.wrongAnswers]) { error in
                if let error = error {
                    self.simpleAlert(title: "Error", msg: error.localizedDescription)
                } else {
                    let wordsForUpdate = self.words.map({ return $0.id == word.id ? word : $0 })
                    self.words = wordsForUpdate
                }
            }
            
        }
    }
}
