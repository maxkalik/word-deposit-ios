import UIKit
import FirebaseAuth

class ForgotPasswordVC: UIViewController {

    // Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loading: RoundedView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loading.isHidden = true
    }
    
    // Actions
    @IBAction func onResetPasswordBtnPress(_ sender: Any) {
        guard let email = emailTextField.text, email.isNotEmpty else {
            simpleAlert(title: "Error", msg: "Fill email field out")
            return
        }
        loading.isHidden = false
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                self.loading.isHidden = true
                self.simpleAlert(title: "Error", msg: error.localizedDescription)
                return
            }
            self.dismiss(animated: true, completion: nil)
            self.loading.isHidden = true
        }
    }
    
    @IBAction func onCancelBtnPress(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
