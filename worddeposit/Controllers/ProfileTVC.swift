import UIKit

/* use the link below where you can store user token */
/* https://github.com/jrendel/SwiftKeychainWrapper */

class ProfileTVC: UITableViewController {
    
    @IBOutlet weak var userFullName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var nativeLanguage: UILabel!
    @IBOutlet weak var notificationsLabel: UILabel!
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var vocabulariesAmount: UILabel!
    @IBOutlet weak var wordsAmountLabel: UILabel!
    @IBOutlet weak var correctAnswersLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    // MARK: - Instances
    
    var user: User! {
        didSet {
            guard let user = user else { return }
            
            if user.firstName.isNotEmpty, user.lastName.isNotEmpty {
                userFullName.text = "\(user.firstName) \(user.lastName)"
            }
            userEmail.text = user.email
            nativeLanguage.text = user.nativeLanguage
            notificationsSwitch.isOn = user.notifications
            DispatchQueue.main.async() {
                self.tableView.reloadData()
            }
        }
    }

    var languages: [String] = []
    var words = [Word]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = UserService.shared.user
        words = UserService.shared.words
        
        getAllLanguages()
        setupStatistics()
        
        notificationsLabel.font = UIFont(name: Fonts.medium, size: 16)
        notificationsLabel.textColor = Colors.dark
        
        logoutButton.titleLabel?.font = UIFont(name: Fonts.bold, size: 16)
    }
    
    // MARK: - Methods
    
    private func getAllLanguages() {
        for code in NSLocale.isoLanguageCodes  {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.languageCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en").displayName(forKey: NSLocale.Key.identifier, value: id) ?? ""
            if name != "" {
                languages.append(name)
            }
        }
        languages.sort()
    }
    
    private func updateUser(_ user: User) {
        UserService.shared.updateUser(user) { error in
            if let error = error {
                UserService.shared.db.handleFirestoreError(error, viewController: self)
                return
            }
        }
    }
    
    private func setupStatistics() {
        vocabulariesAmount.text = String(UserService.shared.vocabularies.count)
        if words.isEmpty {
            self.wordsAmountLabel.text = "0"
            self.correctAnswersLabel.text = "0%"
        } else {
            self.wordsAmountLabel.text = String(words.count)
            
            var rightAnswers = 0;
            var wrongAnswers = 0;
            
            for word in words {
                rightAnswers += word.rightAnswers
                wrongAnswers += word.wrongAnswers
                self.words.append(word)
            }
            
            if rightAnswers == 0 {
                self.correctAnswersLabel.text = "0%"
            } else {
                let answersSum = rightAnswers + wrongAnswers
                let precentageOfCorrectAnswers = (rightAnswers * 100) / answersSum
                self.correctAnswersLabel.text = "\(precentageOfCorrectAnswers)%"
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        // capitalize first letter
        header.textLabel?.text =  header.textLabel?.text?.capitalized
        
        guard let label = header.textLabel else { return }
        label.font = UIFont(name: Fonts.bold, size: 18)
        label.textColor = Colors.dark
        guard let text = label.text else { return }
        label.addCharactersSpacing(spacing: -0.4, text: text)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.font = UIFont(name: Fonts.medium, size: 16)
        cell.textLabel?.textColor = Colors.dark
        cell.detailTextLabel?.font = UIFont(name: Fonts.medium, size: 14)
        cell.detailTextLabel?.textColor = Colors.dark
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        if section == 3 {
            let versionLabel = UILabel()
            versionLabel.frame = CGRect(x: 0, y: 0, width: view.frame.size.width - 40, height: 60)
            versionLabel.font = UIFont(name: Fonts.medium, size: 15)
            versionLabel.textColor = Colors.grey
            versionLabel.textAlignment = .center
            versionLabel.text = "Version 2.1"
            footerView.addSubview(versionLabel)
        }
        return footerView
    }
    
    // MARK: - IBActions
    
    @IBAction func logOut(_ sender: UIButton) {
        UserService.shared.logout { error in
            if let error = error {
                UserService.shared.auth.handleFireAuthError(error, viewController: self)
                return
            }
            showLoginVC(view: self.view)
        }
    }
    
    @IBAction func notificationSwitched(_ sender: UISwitch) {
        user.notifications = sender.isOn
        updateUser(user)
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let userInfoTVC = segue.destination as? UserInfoTVC {
            userInfoTVC.firstName = user.firstName
            userInfoTVC.lastName = user.lastName
            userInfoTVC.email = user.email
            userInfoTVC.delegate = self
            userInfoTVC.title = "User Info"
        }
        
        if let tvc = segue.destination as? CheckmarkListTVC {
            tvc.delegate = self
            switch segue.identifier {
            case Segues.NativeLanguage:
                
                let currentLanguageCode = NSLocale.current.languageCode ?? "en"
                let defaultLanguage = NSLocale(localeIdentifier: currentLanguageCode).displayName(forKey: NSLocale.Key.identifier, value: currentLanguageCode) ?? "English"
                
                let currentLanguage = user.nativeLanguage.isNotEmpty ? user.nativeLanguage : defaultLanguage
                guard let selected = languages.firstIndex(of: currentLanguage) else { return }
                
                tvc.navigationItem.rightBarButtonItem = nil
                tvc.data = languages
                tvc.selected = selected
                tvc.title = "Native Language"
            default:
                break
            }
        }
        
        if let webvc = segue.destination as? WKWebVC {
            switch segue.identifier {
            case Segues.PrivacyAndSecurity:
                webvc.link = "https://www.worddeposit.com/privacy-policy"
            case Segues.FAQ:
                webvc.link = "https://www.worddeposit.com"
            case Segues.About:
                webvc.link = "https://www.worddeposit.com/about"
            default:
                webvc.link = "https://www.worddeposit.com"
            }
        }
    }
}

// MARK: - UserInfoTVCDelegate

extension ProfileTVC: UserInfoTVCDelegate {
    func updateUserInfo(firstName: String, lastName: String) {
        user.firstName = firstName
        user.lastName = lastName
        updateUser(user)
    }
}

extension ProfileTVC: CheckmarkListTVCDelegate {
    func getCheckmared(index: Int) {
        user.nativeLanguage = languages[index]
        updateUser(user)
    }
}
