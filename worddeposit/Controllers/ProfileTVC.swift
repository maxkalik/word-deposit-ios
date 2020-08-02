import UIKit
import FirebaseAuth
import FirebaseFirestore

/* use the link below where you can store user token */
/* https://github.com/jrendel/SwiftKeychainWrapper */

class ProfileTVC: UITableViewController {
    
    @IBOutlet weak var userFullName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var wordsAmount: UILabel!
    @IBOutlet weak var nativeLanguage: UILabel!
    @IBOutlet weak var notificationsSwitch: UISwitch!
    
    // MARK: - Instances
    
    var user: User! {
        didSet {
            guard let user = user else { return }
            
            if user.firstName != "", user.lastName != "" {
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
    var auth: Auth!
    var db: Firestore!
    var profileRef: DocumentReference!
    var handle: AuthStateDidChangeListenerHandle?
    var languages: [String] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = User()
        auth = Auth.auth()
        db = Firestore.firestore()
        getAllLanguages()
        getDefaults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCurrentUser()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        auth.removeStateDidChangeListener(handle!)
    }
    
    // MARK: - Methods
    
    private func getDefaults() {
        let defaults = UserDefaults.standard
        // print(defaults.string(forKey: "native_language"))
        guard let defaultNativeLanguage = defaults.string(forKey: "native_language") else { return }
        let defaultNotifications = defaults.bool(forKey: "notifications")
        user.nativeLanguage = defaultNativeLanguage
        user.notifications = defaultNotifications
    }
    
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
                    self.fetchWords(from: userRef)
                } else {
                    print("Document does not exist")
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
            guard let documents = snapshot?.documents else { return }
            self.wordsAmount.text = String(documents.count)
        }
    }
    
    private func updateProfile(user: User) {
        profileRef = db.collection("users").document(user.id)
        let data = User.modelToData(user: user)
        profileRef.updateData(data) { error in
            if let error = error {
                debugPrint(error)
            } else {
                print("success")
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
       do {
            try auth.signOut()
            // clear all listeners and ui
            showLoginVC()
        } catch let error as NSError {
            simpleAlert(title: "Error", msg: error.localizedDescription)
            debugPrint(error.localizedDescription)
        }
    }
    
    @IBAction func notificationSwitched(_ sender: UISwitch) {
        user.notifications = sender.isOn
        updateProfile(user: user)
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
                let currentLanguage = defaultLanguage != user.nativeLanguage ? user.nativeLanguage : defaultLanguage
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
//            webvc.modalPresentationStyle = .overFullScreen
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
        updateProfile(user: user)
    }
}

extension ProfileTVC: ProfileTVCCheckmarkDelegate {
    func getCheckmared(checkmarked: Int, segueId: String) {
        print(languages[checkmarked], segueId)
        switch segueId {
        case Segues.NativeLanguage:
            user.nativeLanguage = languages[checkmarked]
            updateProfile(user: user)
        default:
            break
        }
    }
}
