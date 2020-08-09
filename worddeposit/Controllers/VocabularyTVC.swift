import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class VocabularyTVC: UITableViewController {
    
    // MARK: - Instances
    
    /// Data model for the table view
    var words = [Word]()
    
    /// Listeners
    var db: Firestore!
    var storage: Storage!
    
    /// References
    var wordsListener: ListenerRegistration!
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
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setWordsListener() // It's good place for network fetch
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let defaults = UserDefaults.standard
        vocabularyId = defaults.string(forKey: "vocabulary_id")
        guard let selectedVocabularyId = vocabularyId else { return }
        print(selectedVocabularyId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        wordsListener.remove()
        words.removeAll()
        tableView.reloadData()
    }
    
    // MARK: - View setups
    
    func setupTableView() {
        let nib = UINib(nibName: XIBs.VocabularyTVCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: XIBs.VocabularyTVCell)
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
    
    // MARK: - Word Listeners for updating Table View
    
    func setWordsListener() {
        // shoud be rewrited
        guard let authUser = Auth.auth().currentUser, let selectedVocabularyId = vocabularyId else { return }
        self.userId = authUser.uid
        let userRef = db.collection("users").document(self.userId)
        let vocabularyRef = userRef.collection("vocabularies").document(selectedVocabularyId)
        self.wordsRef = vocabularyRef.collection("words")
        let wordsRefOrdered = vocabularyRef.collection("words").order(by: "timestamp", descending: true)
        wordsListener = wordsRefOrdered.addSnapshotListener({ (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            snapshot?.documentChanges.forEach({ (docChange) in
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
            // cell is reusable so before calling it we have to nil an image because it can show an image from previous usage
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

                // TODO: shoud be rewrited in the singleton if needed
//                guard let user = Auth.auth().currentUser else { return }
                
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
