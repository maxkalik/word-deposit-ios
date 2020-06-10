import UIKit
import Firebase
import FirebaseFirestore

class RegistrationVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loading: RoundedView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loading.isHidden = true
    }
    
    @IBAction func onSignUpBtnPress(_ sender: Any) {

        guard let email = emailTextField.text, email.isNotEmpty,
            let password = passwordTextField.text, password.isNotEmpty else {
                simpleAlert(title: "Error", msg: "Please fill out all fields.")
                return
        }
        loading.isHidden = false
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error { self.showError(error) }
            
            guard let firUser = authResult?.user else { return }
            let user = User.init(id: firUser.uid, email: email)
            self.createUserInFirestore(user: user)
        }
    }
    
    func createUserInFirestore(user: User) {
        let newUserRef = Firestore.firestore().collection("users").document(user.id)
        let data = User.modelToData(user: user)
        
        newUserRef.setData(data) { (error) in
            if let error = error {
                self.showError(error)
            } else {
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                let homeViewController = storyboard.instantiateViewController(identifier: "home") as? UITabBarController
                self.view.window?.rootViewController = homeViewController
            }
            self.loading.isHidden = true
        }
    }
    
    func showError(_ error: Error) {
        self.simpleAlert(title: "Error", msg: error.localizedDescription)
        self.loading.isHidden = true
        return
    }
    
    @IBAction func onHaveAccountBtnPress(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
