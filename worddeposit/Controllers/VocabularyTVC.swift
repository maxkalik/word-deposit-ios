import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class VocabularyTVC: UITableViewController {
    
    // MARK: - Instances
    
    /// Data model for the table view
    var words = [Word]()
    var messageView = MessageView()
    
    /// Listeners
    var db: Firestore!
    var storage: Storage!
    var wordsListener: ListenerRegistration!
    var vocabulariesListener: ListenerRegistration!
    
    /// References
    var wordsRef: CollectionReference!
    
    /// Search controller to help us with filtering items in the table view
    var searchController: UISearchController!
    
    /// Search results table view
    private var resultsTableController: VocabularyResultsTVC!
    
    /// Restoration state for UISearchController
    var restoredState = SearchControllerRestorableState()
    
    /// Strings
    var userId: String!
    var vocabularyId: String?
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        storage = Storage.storage()
        setupTableView()
        setupResultsTableController()
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.addSubview(messageView)
        setupMessageView()
        messageView.hide()
        setVocabulariesListener()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Restore the searchController's active state.
        if restoredState.wasActive {
            searchController.isActive = restoredState.wasActive
            restoredState.wasActive = false
            
            if restoredState.wasFirstResponder {
                searchController.searchBar.becomeFirstResponder()
                restoredState.wasFirstResponder = false
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vocabulariesListener.remove()
        wordsListener.remove()
        words.removeAll()
        tableView.reloadData()
    }
    
    // MARK: - View setups
    
    func setupMessageView() {
        messageView.show()
        messageView.setTitles(messageTxt: "You have no words yet", buttonTitle: "Add words")
        messageView.onButtonTap { self.tabBarController?.selectedIndex = 1 }
    }
    
    func setupTableView() {
        let nib = UINib(nibName: XIBs.VocabularyTVCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: XIBs.VocabularyTVCell)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReusableIdentifiers.MessageView)
    }
    
    func setupResultsTableController() {
        resultsTableController = self.storyboard?.instantiateViewController(withIdentifier: Storyboards.VocabularyResults) as? VocabularyResultsTVC
        resultsTableController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.sizeToFit()
        searchController.searchBar.searchBarStyle = .minimal
        searchController.definesPresentationContext = true
        searchController.searchBar.delegate = self // Monitor when the search button is tapped
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Place the search bar in the nav bar
        navigationItem.searchController = searchController

        // Make the search bar always visible
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: - Listeners for updating Table View
    
    private func setVocabulariesListener() {
        guard let authUser = Auth.auth().currentUser else { return }
        self.userId = authUser.uid
        let userRef = db.collection("users").document(self.userId)
        let vocabulariesRef = userRef.collection("vocabularies")
        vocabulariesListener = vocabulariesRef.whereField("is_selected", isEqualTo: true).addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let vocabulary = Vocabulary.init(data: data)
                    let defaults = UserDefaults.standard
                    defaults.set(vocabulary.id, forKey: "vocabulary_id")
                    self.words.removeAll()
                    self.tableView.reloadData()
                    
                    // fetch words from current vocabulary
                    self.setWordsListener(vocabularyRef: vocabulariesRef.document(vocabulary.id))
                }
            }
        }
    }
    
    func setWordsListener(vocabularyRef: DocumentReference) {
        
        self.wordsRef = vocabularyRef.collection("words")
        let wordsRefOrdered = vocabularyRef.collection("words").order(by: "timestamp", descending: true)
        wordsListener = wordsRefOrdered.addSnapshotListener({ (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            } else {
                
                guard let snap = snapshot else { return }
                
                if snap.documents.isEmpty {
                    DispatchQueue.main.async {
                        self.setupMessageView()
                    }
                }
                
                snap.documentChanges.forEach({ (docChange) in
                    let data = docChange.document.data()
                    let word = Word.init(data: data)
                    
                    switch docChange.type {
                    case .added:
                        self.onDocumentAdded(change: docChange, word: word)
                    case .modified:
                        self.onDocumentModified(change: docChange, word: word)
                    case .removed:
                        self.onDocumentRemoved(change: docChange)
                    }
                })
            }
        })
    }
    
    func onDocumentAdded(change: DocumentChange, word: Word) {
        let newIndex = Int(change.newIndex)
        words.insert(word, at: newIndex)
        tableView.insertRows(at: [IndexPath(item: newIndex, section: 0)], with: .fade)
    }
    
    func onDocumentModified(change: DocumentChange, word: Word) {
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            words[index] = word
            tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .none)
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            words.remove(at: oldIndex)
            words.insert(word, at: newIndex)
            tableView.moveRow(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
    }
    
    func onDocumentRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        words.remove(at: oldIndex)
        tableView.deleteRows(at: [IndexPath(item: oldIndex, section: 0)], with: .fade)
    }
}

// MARK: - UITableViewDelegate

extension VocabularyTVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = VocabularyCardsVC()
        
        if tableView === self.tableView {
            vc.words = words
        } else {
            vc.words = resultsTableController.filteredWords
        }
        vc.wordIndexPath = indexPath.row
        
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
        // ?
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - UITableViewDataSource

extension VocabularyTVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: XIBs.VocabularyTVCell, for: indexPath) as? VocabularyTVCell {
            cell.configureCell(word: words[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - UITableViewCell Editing

extension VocabularyTVC {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            let selectedWord: Word!
            // Check to see which table view cell was selected
            if tableView === self.tableView {
                selectedWord = words[indexPath.row]
            } else {
                selectedWord = resultsTableController.filteredWords[indexPath.row]
            }

            self.wordsRef.document(selectedWord.id).delete { (error) in
                if let error = error {
                    self.simpleAlert(title: "Error", msg: error.localizedDescription)
                    debugPrint(error.localizedDescription)
                    return
                }
                
                guard let userId = self.userId, let selectedVocabularyId = self.vocabularyId else { return }
                if selectedWord.imgUrl.isNotEmpty {
                    self.storage.reference().child("/\(userId)/\(selectedVocabularyId)/\(selectedWord.id).jpg").delete { (error) in
                        if let error = error {
                            self.simpleAlert(title: "Error", msg: error.localizedDescription)
                            debugPrint(error.localizedDescription)
                            return
                        }
                    }
                }
            }
        }
    }
}


// MARK: - UISearchBarDelegate

extension VocabularyTVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResults(for: searchController)
    }
}

// MARK: - UISearchControllerDelegate

// These delegate functions for additional control over the search controller

extension VocabularyTVC: UISearchControllerDelegate {

    func presentSearchController(_ searchController: UISearchController) {
        //Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        //Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        //Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        //Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        //Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
}
