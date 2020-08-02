import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
//    @IBOutlet weak var loader: RoundedView!
    var progressHUD = ProgressHUD()
    
    // MARK: - Instances
    
    var auth: Auth!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        auth = Auth.auth()
        self.view.addSubview(progressHUD)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        progressHUD.hide()
    }
    
    // MARK: - Methods
    func showHomeVC() {
        let storyboard = UIStoryboard(name: Storyboards.Home, bundle: nil)
        let homeViewController = storyboard.instantiateViewController(identifier: Storyboards.Home) as? UITabBarController
        self.view.window?.rootViewController = homeViewController
        self.view.window?.makeKeyAndVisible()
    }
    
    // MARK: - IBActions
    @IBAction func onSignInBtnPress(_ sender: Any) {
        progressHUD.show()
        guard let email = emailTextField.text, email.isNotEmpty,
              let password = passwordTextField.text, password.isNotEmpty else {
                simpleAlert(title: "Error", msg: "Please fill out all fields")
                return
        }
        
        auth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.simpleAlert(title: "Error", msg: error.localizedDescription)
                return
            }
            self?.progressHUD.hide()
            self?.showHomeVC()
        }
    }
}
