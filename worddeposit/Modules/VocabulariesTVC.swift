import UIKit

protocol VocabulariesTVCDelegate: VocabularyTVC {
    func onVocabulariesTVCDismiss()
}

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
    

    weak var delegate: VocabulariesTVCDelegate?
    
    private var messageView = MessageView()
    private var progressHUD = ProgressHUD()
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(vocabularyDidSwitch), name: Notification.Name(Keys.vocabulariesSwitchNotificationKey), object: nil)
        nc.addObserver(self, selector: #selector(vocabularySwitchBegan), name: Notification.Name(Keys.vocabulariesSwitchBeganNotificationKey), object: nil)
        setupTableView()
        view.addSubview(messageView)
        view.superview?.addSubview(progressHUD)
        prepareContent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        messageView.frame.origin.y = tableView.contentOffset.y
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupMessage()
        messageView.hide()
        checkVocabulariesExist()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self)
        delegate?.onVocabulariesTVCDismiss()
    }
    
    // MARK: - Methods
    
    // fetching content and add it to the view
    private func prepareContent() {
        if UserService.shared.vocabularies.count > 0 {
            self.vocabularies.removeAll()
            self.tableView.reloadData()
            self.backButton.isEnabled = true
            /// main queue dispatching here because we need to avoid a warning UITableViewAlertForLayoutOutsideViewHierarchy
            DispatchQueue.main.async { [self] in
                for index in 0..<UserService.shared.vocabularies.count {
                    vocabularies.append(UserService.shared.vocabularies[index])
                    tableView.insertRows(at: [IndexPath(item: index, section: 0)], with: .fade)
                }
            }
        } else {
            backButton.isEnabled = false
        }
    }
    
    private func checkVocabulariesExist() {
        if UserService.shared.vocabularies.isEmpty {
            self.setupMessage()
            self.messageView.show()
            self.tableView.isScrollEnabled = false
            self.isModalInPresentation = true
        } else {
            self.tableView.isScrollEnabled = true
            self.isModalInPresentation = false
        }
    }
    
    func vocabularyDidCreate(_ vocabulary: Vocabulary) {
        vocabularies.insert(vocabulary, at: 0)
        tableView.reloadData()
        if vocabularies.count == 1 {
            backButton.isEnabled = true
            UserService.shared.getCurrentVocabulary()
            NotificationCenter.default.post(name: Notification.Name(Keys.vocabulariesSwitchNotificationKey), object: nil)
        }
    }
    
    func vocabularyDidUpdate(_ vocabulary: Vocabulary, index: Int) {
        vocabularies[index] = vocabulary // TODO: - index out of range
        tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .fade)
    }
    
    func vocabularyDidRemove(_ vocabulary: Vocabulary, index: Int) {
        vocabularies.remove(at: index)
        tableView.reloadData()
    }
    
    private func setupMessage() {
        messageView.setTitles(
            messageTxt: "You haven't created any vocabularies yet.\nPlease add them.",
            buttonTitle: "+ Add vocabulary",
            secondaryButtonTitle: "Logout"
        )
        messageView.showSecondaryButton()
        messageView.onPrimaryButtonTap { [unowned self] in
            self.performSegue(withIdentifier: Segues.VocabularyDetails, sender: nil)
        }
        messageView.onSecondaryButtonTap {
            self.progressHUD.show()
            UserService.shared.logout { error in
                if let error = error {
                    self.progressHUD.hide()
                    UserService.shared.auth.handleFireAuthError(error, viewController: self)
                    return
                }
                self.progressHUD.hide()
                PresentVC.loginVC(from: self.view)
            }
        }
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: XIBs.VocabulariesTVCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: XIBs.VocabulariesTVCell)
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tableView.backgroundColor = Colors.silver
    }
    
    @objc private func checkboxChanged(sender: Checkbox) {
        if vocabularies.count == 1 {
            sender.isOn = true
            simpleAlert(title: "You cannot unmarked actived vocabulary.", msg: "Create another one for swithing between them.")
        } else {
            let newSelectedVocabularyIndex = sender.tag
            if newSelectedVocabularyIndex != selectedVocabularyIndex {
                guard let oldIndex = selectedVocabularyIndex else { return }
                selectedVocabularyIndex = newSelectedVocabularyIndex
                tableView.reloadRows(at: [IndexPath(item: oldIndex, section: 0), IndexPath(item: newSelectedVocabularyIndex, section: 0)], with: .fade)
                NotificationCenter.default.post(name: Notification.Name(Keys.vocabulariesSwitchBeganNotificationKey), object: nil)

                UserService.shared.switchSelectedVocabulary(from: vocabularies[oldIndex], to: vocabularies[newSelectedVocabularyIndex]) { error in
                    if let error = error {
                        UserService.shared.db.handleFirestoreError(error, viewController: self)
                        return
                    }
                    
                    UserService.shared.getCurrentVocabulary()
                    UserService.shared.fetchWords { error, _ in
                        if let error = error {
                            UserService.shared.db.handleFirestoreError(error, viewController: self)
                            return
                        }
                        /// Post notification for Practice and Vocabulary views
                        NotificationCenter.default.post(name: Notification.Name(Keys.vocabulariesSwitchNotificationKey), object: nil)
                    }
                }
            } else {
                sender.isOn = true
                simpleAlert(title: "Vocabulary alert", msg: "You cannot unmarked actived vocabulary. Mark another one.")
            }
        }
    }
    
    @objc func vocabularyDidSwitch() {
        print("vocabularies -- notification is called")
    }
    
    @objc func vocabularySwitchBegan() {
        print("vocabularies -- notification switch began is called")
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vocabularies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: XIBs.VocabulariesTVCell, for: indexPath) as? VocabulariesTVCell {
            
            cell.backgroundColor = .clear
            
            let vocabulary = vocabularies[indexPath.row]
            cell.configureCell(vocabulary: vocabulary)
            cell.isSelectedVocabulary = false
            if vocabulary.isSelected == true {
                cell.isSelectedVocabulary = true
                selectedVocabularyIndex = indexPath.row
            }
            cell.checkbox.tag = indexPath.row
            cell.checkbox.addTarget(self, action: #selector(checkboxChanged(sender:)), for: .touchUpInside)
            return cell
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let vocabulary = vocabularies[indexPath.row]
            if vocabulary.isSelected {
                simpleAlert(title: "You cannot delete", msg: "Before removing vocabulary, please switch to another vocabulary")
            } else {
                let alert = UIAlertController(title: title, message: "Are you sure?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Remove", style: .default, handler: { (action) in
                    UserService.shared.removeVocabulary(vocabulary) { error in
                        if error != nil {
                            self.simpleAlert(title: "Error", msg: "Cannot remove vocabulary. Try to reload an app")
                            return
                        }
                        self.vocabularyDidRemove(vocabulary, index: indexPath.row)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit") { (_, _, success) in
            self.performSegue(withIdentifier: Segues.VocabularyDetails, sender: indexPath.row)
        }
        edit.backgroundColor = Colors.dark
        return UISwipeActionsConfiguration(actions: [edit])
    }

    // MARK: - IBOutlets
    
    @IBAction func backButtonTaped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Navigation

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.dequeueReusableCell(withIdentifier: XIBs.VocabulariesTVCell, for: indexPath) as? VocabulariesTVCell {
            cell.checkbox.tag = indexPath.row
            checkboxChanged(sender: cell.checkbox)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vocabularyDetailsVC = segue.destination as? VocabularyDetailsVC {
            vocabularyDetailsVC.delegate = self
            if let index = sender as? Int {
                vocabularyDetailsVC.vocabulary = vocabularies[index]
            }
            if vocabularies.count > 0 {
                vocabularyDetailsVC.isFirstSelected = false
            }
        }
    }
}

