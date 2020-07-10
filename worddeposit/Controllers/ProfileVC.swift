import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileVC: UIViewController {
    
    // MARK: - Instances
    
    var user = User()
    var auth: Auth!
    var db: Firestore!
    var handle: AuthStateDidChangeListenerHandle?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            guard let user = auth.currentUser else { return }
            let userRef = self.db.collection("users").document(user.uid)
            userRef.getDocument { (document, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }
                if let document = document, document.exists {
                    guard let data = document.data() else { return }
                    self.user = User.init(data: data)
                    print(self.user)
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    private func showLoginVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(identifier: Storyboards.Login)
        self.view.window?.rootViewController = loginVC
        self.view.window?.makeKeyAndVisible()
    }
    
    // MARK: - IBActions
    
    @IBAction func onSignOutBtnPress(_ sender: Any) {
        do {
            try auth.signOut()
            // clear all listeners and ui
            showLoginVC()
        } catch let error as NSError {
            simpleAlert(title: "Error", msg: error.localizedDescription)
            debugPrint(error.localizedDescription)
        }
    }
}
