import UIKit
import Firebase
import FirebaseFirestore

private let reuseIdentifier = XIBs.PracticeCVCell
private let minWordsAmount = 10
class PracticeCVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIPopoverPresentationControllerDelegate {

    // MARK: - Instances
    
    var user = User()
    var words = [Word]()
    var auth: Auth!
    var db: Firestore!
    var handle: AuthStateDidChangeListenerHandle?
    var practiceReadVC: PracticeReadVC?
    var progressHUD = ProgressHUD(title: "Welcome")
    var messageView = MessageView()
    
    private var trainers = [PracticeTrainer]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        auth = Auth.auth()
        db = Firestore.firestore()
        
        trainers = PracticeTrainers().data

        // Register cell classes
        let nib = UINib(nibName: XIBs.PracticeCVCell, bundle: nil)
        let messageNib = UINib(nibName: XIBs.MessageCVCell, bundle: nil)
        self.collectionView!.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(messageNib, forCellWithReuseIdentifier: XIBs.MessageCVCell)
        self.collectionView!.isPrefetchingEnabled = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let flowlayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowlayout.minimumLineSpacing = 20
        }
        getCurrentUser()

        self.view.addSubview(progressHUD)
//        self.view.addSubview(messageView)
//        messageView.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        auth.removeStateDidChangeListener(handle!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    // MARK: - Methods
    
    private func getCurrentUser() {
        handle = auth.addStateDidChangeListener { (auth, user) in
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
                    self.progressHUD.setTitle(title: "\(self.user.firstName) \(self.user.lastName)")
                    // user defaults
                    let defaults = UserDefaults.standard
                    defaults.set(self.user.nativeLanguage, forKey: "native_language")
                    defaults.set(self.user.notifications, forKey: "notifications")
                    defaults.set(Date(), forKey: "last_run")
                    
                    self.fetchVocabularies(from: userRef)
                    
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    private func fetchVocabularies(from: DocumentReference) {
        let vocabularyRef = from.collection("vocabularies")
        vocabularyRef.whereField("is_selected", isEqualTo: true).addSnapshotListener() { (querySnapshot, err) in
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
        let wordsRef = from.collection("words")
        
        wordsRef.getDocuments { (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            self.words.removeAll()
            self.progressHUD.hide()
            guard let documents = snapshot?.documents else { return }
            
            if documents.isEmpty {
                print("no words")
            }
            
            for document in documents {
                let data = document.data()
                let word = Word.init(data: data)
                self.words.append(word)
            }
            self.collectionView.reloadData()
            print(self.words)
        }
    }
    
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

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if words.count > minWordsAmount {
            return trainers.count
        } else {
            return 1
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if words.count > minWordsAmount {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PracticeCVCell {
                let trainer = trainers[indexPath.row]
                cell.backgroundColor = trainer.backgroundColor
                cell.configureCell(cover: trainer.coverImageSource, title: trainer.title)
                return cell
            }
        }
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: XIBs.MessageCVCell, for: indexPath) as? MessageCVCell {
                cell.messageView.setTitles(messageTxt: "You have no sufficient amount of words. Add at least \(minWordsAmount - words.count) words", buttonTitle: "Add more words")
                cell.messageView.onButtonTap {
                    print("pressed")
                    self.tabBarController?.selectedIndex = 1
                }
                return cell
            }
            
        return PracticeCVCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        if words.count < minWordsAmount {
            return CGSize(width: screenSize.width - 40, height: screenSize.height - collectionView.safeAreaInsets.top - collectionView.safeAreaInsets.bottom)
        }
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
//        practiceReadVC?.trainedWord = wordsDesk.randomElement()
        practiceReadVC?.wordsDesk = wordsDesk
    }
}
