import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegistrationVC: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var progressHUD = ProgressHUD()

    // MARK: - Instances
    
    var auth: Auth!
    var db: Firestore!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        auth = Auth.auth()
        db = Firestore.firestore()
        self.view.addSubview(progressHUD)
        progressHUD.hide()
    }
    
    // MARK: - Methods
    
    func createUserInFirestore(user: User) {
        let newUserRef = db.collection("users").document(user.id)
        let data = User.modelToData(user: user)
        
        newUserRef.setData(data) { (error) in
            if let error = error {
                self.showError(error)
                self.progressHUD.hide()
            } else {
                self.progressHUD.hide()
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                let homeViewController = storyboard.instantiateViewController(identifier: Storyboards.Home) as? UITabBarController
                self.view.window?.rootViewController = homeViewController
            }
        }
    }
    
    func showError(_ error: Error) {
        self.simpleAlert(title: "Error", msg: error.localizedDescription)
        self.progressHUD.hide()
        return
    }
    
    // MARK: - IBActions
    
    @IBAction func onSignUpBtnPress(_ sender: UIButton) {

        guard let email = emailTextField.text, email.isNotEmpty,
            let password = passwordTextField.text, password.isNotEmpty else {
                simpleAlert(title: "Error", msg: "Please fill out all fields.")
                return
        }
        self.progressHUD.show()
        
        auth.createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error { self.showError(error) }
            
            guard let firUser = authResult?.user else { return }
            let user = User.init(id: firUser.uid, email: email)
            self.createUserInFirestore(user: user)
        }
    }
    
    
    @IBAction func onHaveAccountBtnPress(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
