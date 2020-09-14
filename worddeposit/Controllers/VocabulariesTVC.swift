import UIKit

class VocabulariesTVC: UITableViewController, VocabularyDetailsVCDelegate {

    // MARK: - Instances
    
    private var vocabularies = [Vocabulary]()
    private var selectedVocabularyIndex: Int? {
        // get first vocabulary is selected
        get {
            if vocabularies.count > 0 {
                let index = vocabularies.firstIndex { vocabulary in
                    return vocabulary.isSelected
                }
                return index
            }
            return nil
        }
        // set only one vocabulary selected
        set {
            for index in vocabularies.indices {
                vocabularies[index].isSelected = index == newValue
            }
        }
    }
    
    private var messageView = MessageView()
    private var progressHUD = ProgressHUD()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(vocabularyDidSwitch), name: Notification.Name(Keys.vocabulariesSwitchNotificationKey), object: nil)
        
        setupTableView()
        view.addSubview(messageView)
        view.superview?.addSubview(progressHUD)
        prepareContent()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupMessage()
        messageView.hide()
        checkVocabulariesExist()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageView.frame.origin.y = tableView.contentOffset.y
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Methods
    
    // fetching content and add it to the view
    private func prepareContent() {
        if UserService.shared.vocabularies.count > 0 {
            self.vocabularies.removeAll()
            self.tableView.reloadData()
            
            /// main queue dispatching here because we need to avoid a warning UITableViewAlertForLayoutOutsideViewHierarchy
             DispatchQueue.main.async {
                for index in 0..<UserService.shared.vocabularies.count {
                    self.vocabularies.append(UserService.shared.vocabularies[index])
                    self.tableView.insertRows(at: [IndexPath(item: index, section: 0)], with: .fade)
                }
             }
        }
    }
    
    private func checkVocabulariesExist() {
        if UserService.shared.vocabularies.isEmpty {
            self.setupMessage()
            self.messageView.show()
            self.isModalInPresentation = true
        } else {
            self.isModalInPresentation = false
        }
    }
    
    func vocabularyDidCreate(_ vocabulary: Vocabulary) {
        self.vocabularies.insert(vocabulary, at: 0)
        self.tableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
    }
    
    func vocabularyDidUpdate(_ vocabulary: Vocabulary, index: Int) {
        self.vocabularies[index] = vocabulary // index out of range
        tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .fade)
    }
    
    func vocabularyDidRemove(_ vocabulary: Vocabulary, index: Int) {
        self.vocabularies.remove(at: index)
        self.tableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: .fade)
    }
    
    private func setupMessage() {
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
            UserService.shared.logout {
                self.progressHUD.hide()
                self.showLoginVC()
            }
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
    
    private func setupTableView() {
        let nib = UINib(nibName: XIBs.VocabulariesTVCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: XIBs.VocabulariesTVCell)
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    @objc func vocabularyDidSwitch() {
        print("vocabularies -- notification is called")
    }
    
    @objc func switchChaged(sender: UISwitch) {
        
        let newSelectedVocabularyIndex = sender.tag
        if newSelectedVocabularyIndex != selectedVocabularyIndex {
            guard let oldIndex = selectedVocabularyIndex else { return }
            selectedVocabularyIndex = newSelectedVocabularyIndex
            tableView.reloadRows(at: [IndexPath(item: oldIndex, section: 0), IndexPath(item: newSelectedVocabularyIndex, section: 0)], with: .fade)
            // update vocabularies request
            UserService.shared.switchSelectedVocabulary(from: vocabularies[oldIndex], to: vocabularies[newSelectedVocabularyIndex]) {
                
                UserService.shared.getCurrentVocabulary()
                
                UserService.shared.fetchWords { _ in
                    // Post notification for Practice and Vocabulary views
                    NotificationCenter.default.post(name: Notification.Name(Keys.vocabulariesSwitchNotificationKey), object: nil)
                }
            }
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
            cell.configureCell(vocabulary: vocabulary)
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
        return true
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            let vocabulary = vocabularies[indexPath.row]
            
            if vocabulary.isSelected {
                simpleAlert(title: "You cannot delete", msg: "Before removing vocabulary, please switch to another vocabulary")
            } else {
                let alert = UIAlertController(title: title, message: "Are you sure?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Remove", style: .default, handler: { (action) in
                    UserService.shared.removeVocabulary(vocabulary) {
                        self.vocabularyDidRemove(vocabulary, index: indexPath.row)
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
