import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileTVC: UITableViewController {
    
    @IBOutlet weak var userFullName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
        
    // MARK: - Instances
    
    var user: User! {
        didSet {
            guard let user = user else { return }
            if user.firstName != "", user.lastName != "" {
                userFullName.text = "\(user.firstName) \(user.lastName)"
            }
            userEmail.text = user.email
            DispatchQueue.main.async() {
                self.tableView.reloadData()
            }
        }
    }
    var auth: Auth!
    var db: Firestore!
    var profileRef: DocumentReference!
    var handle: AuthStateDidChangeListenerHandle?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = User()
        auth = Auth.auth()
        db = Firestore.firestore()
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
                    
                } else {
                    print("Document does not exist")
                }
            }
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: Segues.UserInfo, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let userInfo = segue.destination as? UserInfoTVC {
            userInfo.firstName = user.firstName
            userInfo.lastName = user.lastName
            userInfo.delegate = self
        }
    }
}

extension ProfileTVC: UserInfoTVCDelegate {
    func updateUserInfo(firstName: String, lastName: String) {
        user.firstName = firstName
        user.lastName = lastName
        updateProfile(user: user)
    }
}
