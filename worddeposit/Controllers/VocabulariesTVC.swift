import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class VocabulariesTVC: UITableViewController, VocabularyDetailsVCDelegate {

    // MARK: - Instances
    
    var vocabularies = [Vocabulary]()
    var selectedVocabularyIndex = 0 {
        didSet {
            let defaults = UserDefaults.standard
            if vocabularies.count > 0 {
                defaults.set(vocabularies[selectedVocabularyIndex].id, forKey: "vocabulary_id")
            }
        }
    }
    
    var messageView = MessageView()
    var progressHUD = ProgressHUD()
    
    var auth: Auth!
    var db: Firestore!
    var storage: Storage!
    var vocabulariesListener: ListenerRegistration!
    var userRef: DocumentReference!
    var vocabulariesRef: DocumentReference!
    
    var userId: String!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        auth = Auth.auth()
        db = Firestore.firestore()
        storage = Storage.storage()
        setupTableView()
        
        guard let authUser = auth.currentUser else { return }
        userRef = db.collection("users").document(authUser.uid)
        userId = authUser.uid
        
        print("view did load")
        // fetching content and add it to the view
        prepareContent()
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(messageView)
        view.superview?.addSubview(progressHUD)
        progressHUD.show()
        
        setupMessage()
        messageView.hide()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageView.frame.origin.y = tableView.contentOffset.y
    }
    
    // MARK: - Methods
    
    // fetching content and add it to the view
    func prepareContent() {
        UserService.shared.fetchVocabularies { vocabularies in
            // self.tableView.reloadData() // we can use updating like on listener
            
            // Add a vocabulary
            for index in 0..<vocabularies.count {
                self.vocabularies.append(vocabularies[index])
                self.tableView.insertRows(at: [IndexPath(item: index, section: 0)], with: .fade)
            }
            
            self.progressHUD.hide()
        }
    }
    
    // clean up all content
    func cleanUpTableView() {
        vocabularies.removeAll()
        tableView.reloadData()
    }
    
    func vocabularyDidCreate(_ vocabulary: Vocabulary) {
        // print(vocabulary)
        
        vocabularies.insert(vocabulary, at: 0)

         tableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
    }
    
    
    
    
    func setupMessage() {
        messageView.setTitles(
            messageTxt: "You have no any vocabularies yet.\nPlease add them.",
            buttonTitle: "+ Add vocabulary",
            secondaryButtonTitle: "Logout"
        )
        messageView.showSecondaryButton()
        messageView.onPrimaryButtonTap { [unowned self] in
            self.performSegue(withIdentifier: Segues.VocabularyDetails, sender: nil)
        }
        messageView.onSecondaryButtonTap {
            self.progressHUD.show()
            self.logout()
        }
    }
    
    func logout() {
        do {
            try auth.signOut()
            // clear all listeners and ui
            progressHUD.hide()
            self.showLoginVC()
        } catch let error as NSError {
            simpleAlert(title: "Error", msg: error.localizedDescription)
            progressHUD.hide()
            debugPrint(error.localizedDescription)
        }
    }
    
    private func showLoginVC() {
       let storyboard = UIStoryboard(name: "Main", bundle: nil)
       let loginVC = storyboard.instantiateViewController(identifier: Storyboards.Login)
        
        guard let window = self.view.window else {
            self.view.window?.rootViewController = loginVC
            self.view.window?.makeKeyAndVisible()
            return
        }
        
        window.rootViewController = loginVC
        window.makeKeyAndVisible()

        let options: UIView.AnimationOptions = .transitionCrossDissolve
        let duration: TimeInterval = 0.3
        
        UIView.transition(with: window, duration: duration, options: options, animations: nil, completion: nil)
    }
    
    
    func setVocabularyListener() {
        let vocabularyQuery = userRef.collection("vocabularies").order(by: "timestamp", descending: true)
        vocabulariesListener = vocabularyQuery.addSnapshotListener({ (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.progressHUD.hide()
                return
            }
            self.progressHUD.hide()

            if snapshot!.documents.isEmpty {
                self.setupMessage()
                self.messageView.show()
                self.isModalInPresentation = true
            } else {
                self.isModalInPresentation = false
            }
            
            snapshot?.documentChanges.forEach({ (docChange) in
                let data = docChange.document.data()
                let vocabulary = Vocabulary.init(data: data)
                switch docChange.type {
                case .added:
                    self.onDocumentAdded(change: docChange, vocabulary: vocabulary)
                case .modified:
                    self.onDocumentModified(change: docChange, vocabulary: vocabulary)
                case .removed:
                    self.onDocumentRemoved(change: docChange)
                }
            })
        })
    }
    

    
    func onDocumentAdded(change: DocumentChange, vocabulary: Vocabulary) {
        let newIndex = Int(change.newIndex)
        vocabularies.insert(vocabulary, at: newIndex)
        tableView.insertRows(at: [IndexPath(item: newIndex, section: 0)], with: .fade)
    }
    
    func onDocumentModified(change: DocumentChange, vocabulary: Vocabulary) {
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            vocabularies[index] = vocabulary
            tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .none)
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            vocabularies.remove(at: oldIndex)
            vocabularies.insert(vocabulary, at: newIndex)
            tableView.moveRow(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
    }
    
    func onDocumentRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        vocabularies.remove(at: oldIndex)
        tableView.deleteRows(at: [IndexPath(item: oldIndex, section: 0)], with: .fade)
    }
    
    func setupTableView() {
        let nib = UINib(nibName: XIBs.VocabulariesTVCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: XIBs.VocabulariesTVCell)
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    func updateVocabulary(_ vocabulary: Vocabulary) {
        // TODO: - Refactoring
        guard let user = auth.currentUser else { return }
        vocabulariesRef = db.collection("users").document(user.uid).collection("vocabularies").document(vocabulary.id)
        // print(vocabulary)
        let data = Vocabulary.modelToData(vocabulary: vocabulary)
        vocabulariesRef.updateData(data) { (error) in
            if let error = error {
                self.simpleAlert(title: "Error", msg: error.localizedDescription)
            }
            // success
            // print("success")
        }
    }
    
    @objc func switchChaged(sender: UISwitch) {
        if sender.tag != selectedVocabularyIndex {
            
            // update old one
            let oldIndex = selectedVocabularyIndex
            vocabularies[oldIndex].isSelected = false
            updateVocabulary(vocabularies[oldIndex])
            
            // update new one
            selectedVocabularyIndex = sender.tag
            var vocabulary = vocabularies[selectedVocabularyIndex]
            vocabulary.isSelected = true
            updateVocabulary(vocabulary)
            
        } else {
            sender.isOn = true
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return vocabularies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: XIBs.VocabulariesTVCell, for: indexPath) as? VocabulariesTVCell {
            let vocabulary = vocabularies[indexPath.row]
            cell.configureCell(vocabulary: vocabulary, userRef: userRef)
            cell.isSelectedVocabulary = false
            if vocabulary.isSelected == true {
                cell.isSelectedVocabulary = true
                selectedVocabularyIndex = indexPath.row
            }
            cell.selectionSwitch.tag = indexPath.row
            cell.selectionSwitch.addTarget(self, action: #selector(switchChaged(sender:)), for: .valueChanged)
            
            return cell
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            let vocabulary = vocabularies[indexPath.row]
            
            if vocabulary.isSelected == true {
                simpleAlert(title: "You cannot delete", msg: "Before removing vocabulary, please switch to another vocabulary")
            } else {
                
                let alert = UIAlertController(title: title, message: "Are you sure?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Remove", style: .default, handler: { (action) in
                    UserService.shared.removeVocabulary(vocabulary) {
                        self.vocabularies.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [IndexPath(item: indexPath.row, section: 0)], with: .fade)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }


    // MARK: - Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Segues.VocabularyDetails, sender: indexPath.row)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vocabularyDetailsVC = segue.destination as? VocabularyDetailsVC {
            vocabularyDetailsVC.delegate = self
            if let index = sender as? Int {
                vocabularyDetailsVC.vocabulary = vocabularies[index]
            }
            // we need to set very first created vocabulary is selected = true
            if vocabularies.count > 0 {
                vocabularyDetailsVC.isFirstSelected = false
            }
        }
    }
}
