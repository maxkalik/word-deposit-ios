import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class VocabularyTVC: UITableViewController {

    // Outlets
//    @IBOutlet weak var tableView: UITableView!
    
    // Variables
    var words = [Word]()
    var db: Firestore!
    var storage: Storage!
    var wordsListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        storage = Storage.storage()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setWordsListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        wordsListener.remove()
        words.removeAll()
        tableView.reloadData()
    }
    
    func setupTableView() {
        
        let nib = UINib(nibName: Identifiers.WordCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Identifiers.WordCell)
    }
    
    func setWordsListener() {
        // shoud be rewrited
        guard let authUser = Auth.auth().currentUser else { return }
        let userRef = db.collection("users").document(authUser.uid)
        let wordsRef = userRef.collection("words")
        wordsListener = wordsRef.addSnapshotListener({ (snapshot, error) in
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

// MARK: - Vocabulary Preparation
// -------- extension -------- //
extension VocabularyTVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.WordCell, for: indexPath) as? WordTableViewCell {
            cell.configureCell(word: words[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = WordsVC()
        vc.words = words
        vc.wordIndexPath = indexPath.row
//        vc.modalPresentationStyle = .overFullScreen
//        vc.isModalInPresentation = true

        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let selectedWord = words[indexPath.row]

            // TODO: shoud be rewrited in the singleton

            guard let user = Auth.auth().currentUser else { return }
            
            db.collection("users").document(user.uid).collection("words").document(selectedWord.id).delete { (error) in
                if let error = error {
                    self.simpleAlert(title: "Error", msg: error.localizedDescription)
                    debugPrint(error.localizedDescription)
                    return
                }

                self.storage.reference().child("/\(user.uid)/\(selectedWord.id).jpg").delete { (error) in
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
