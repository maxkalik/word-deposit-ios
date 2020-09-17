import UIKit

/* use the link below where you can store user token */
/* https://github.com/jrendel/SwiftKeychainWrapper */

class ProfileTVC: UITableViewController {
    
    @IBOutlet weak var userFullName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var nativeLanguage: UILabel!
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var wordsAmountLabel: UILabel!
    @IBOutlet weak var correctAnswersLabel: UILabel!
    
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
        // print(words)
        
        print("view did load")
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
    
    private func setupStatistics() {
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
    
    private func showLoginVC() {
       let storyboard = UIStoryboard(name: Storyboards.Main, bundle: nil)
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        if section == 3 {
            let versionLabel = UILabel()
            versionLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width - 40, height: 60)
            versionLabel.font = UIFont.systemFont(ofSize: 14)
            versionLabel.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            versionLabel.textAlignment = .center
            versionLabel.text = "Version 2.0.0"
            footerView.addSubview(versionLabel)
        }
        return footerView
    }
    
    // MARK: - IBActions
    
    @IBAction func logOut(_ sender: UIButton) {
        UserService.shared.logout {
            self.showLoginVC()
        }
    }
    
    @IBAction func notificationSwitched(_ sender: UISwitch) {
        user.notifications = sender.isOn
        UserService.shared.updateUser(user)
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
        
        if let tvc = segue.destination as? ProfileTVCCheckmark {
            tvc.delegate = self
            tvc.segueId = segue.identifier
            switch segue.identifier {
            case Segues.NativeLanguage:
                
                let currentLanguageCode = NSLocale.current.languageCode ?? "en"
                let defaultLanguage = NSLocale(localeIdentifier: currentLanguageCode).displayName(forKey: NSLocale.Key.identifier, value: currentLanguageCode) ?? "English"
                
                let currentLanguage = user.nativeLanguage.isNotEmpty ? user.nativeLanguage : defaultLanguage
                guard let selected = languages.firstIndex(of: currentLanguage) else { return }
                
                tvc.data = languages
                tvc.selected = selected
                tvc.title = "Native Language"
            case Segues.AccountType:
                tvc.data = ["Regular"]
                tvc.selected = 0
                tvc.title = "Account"
            case Segues.Appearance:
                tvc.data = ["Dark", "Light"]
                tvc.selected = 0
                tvc.title = "Appearance"
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
        UserService.shared.updateUser(user)
    }
}

extension ProfileTVC: ProfileTVCCheckmarkDelegate {
    func getCheckmared(checkmarked: Int, segueId: String) {
        switch segueId {
        case Segues.NativeLanguage:
            user.nativeLanguage = languages[checkmarked]
            UserService.shared.updateUser(user)
        default:
            break
        }
    }
}
