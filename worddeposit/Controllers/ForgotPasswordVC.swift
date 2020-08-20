import UIKit
import FirebaseAuth

class ForgotPasswordVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    var progressHUD = ProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressHUD.hide()
    }
    
    // MARK: - IBActions
    @IBAction func onResetPasswordBtnPress(_ sender: RoundedButton) {
        guard let email = emailTextField.text, email.isNotEmpty else {
            simpleAlert(title: "Error", msg: "Fill email field out")
            return
        }
        progressHUD.show()
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                self.progressHUD.hide()
                self.simpleAlert(title: "Error", msg: error.localizedDescription)
                return
            }
            self.navigationController?.popViewController(animated: true)
            self.progressHUD.hide()
        }
    }
    
    @IBAction func onCancelBtnPress(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
