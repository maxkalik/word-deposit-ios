import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
    
    // Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loader: RoundedView!
    
    // Variables
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.isHidden = true
    }
    
    func showHomeVC() {
        let storyboard = UIStoryboard(name: Storyboards.Home, bundle: nil)
        let homeViewController = storyboard.instantiateViewController(identifier: Storyboards.Home) as? UITabBarController
        self.view.window?.rootViewController = homeViewController
        self.view.window?.makeKeyAndVisible()
    }
    
    // Actions
    @IBAction func onSignInBtnPress(_ sender: Any) {
        loader.isHidden = false
        guard let email = emailTextField.text, email.isNotEmpty,
              let password = passwordTextField.text, password.isNotEmpty else {
                loader.isHidden = true
                simpleAlert(title: "Error", msg: "Please fill out all fields")
                return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if let error = error {
                self.loader.isHidden = true
                self.simpleAlert(title: "Error", msg: error.localizedDescription)
                return
            }
            self.loader.isHidden = true
            self.showHomeVC()
        }
    }
}
