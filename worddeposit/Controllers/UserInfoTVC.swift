import UIKit
import FirebaseAuth

protocol UserInfoTVCDelegate: AnyObject {
    func updateUserInfo(firstName: String, lastName: String)
}

class UserInfoTVC: UITableViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var firstNameTextField: CellTextField!
    @IBOutlet weak var lastNameTextField: CellTextField!
    @IBOutlet weak var oldPasswordTextField: CellTextField!
    @IBOutlet weak var newPasswordTextField: CellTextField!
    
    // MARK: - Instances
    
    var auth: Auth!
    var email: String!
    var firstName: String!
    var lastName: String!
    weak var delegate: UserInfoTVCDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        auth = Auth.auth()
        firstNameTextField.text = firstName
        lastNameTextField.text = lastName
        doneButton.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        firstNameTextField.addTarget(self, action: #selector(userNameDidChange), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(userNameDidChange), for: .editingChanged)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        firstNameTextField.removeTarget(self, action: #selector(userNameDidChange), for: .editingChanged)
        lastNameTextField.removeTarget(self, action: #selector(userNameDidChange), for: .editingChanged)
    }
    
    // MARK: - Methods
    
    @objc func userNameDidChange(_ textField: CellTextField) {
        guard let first = firstNameTextField.text, let last = lastNameTextField.text else { return }
        if first.isNotEmpty && first != firstName || last.isNotEmpty && last != lastName {
            doneButton.isEnabled = true
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func doneTouched(_ sender: UIBarButtonItem) {
        guard let first = firstNameTextField.text, let last = lastNameTextField.text else { return }
        delegate?.updateUserInfo(firstName: first, lastName: last)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetPasswordTouched(_ sender: UIButton) {
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("password reset success")
            }
        }
    }
    
    @IBAction func deleteAccountTouched(_ sender: UIButton) {
        let user = auth.currentUser
        user?.delete { error in
          if let error = error {
            print(error.localizedDescription)
          } else {
            print("account deleted successfully")
          }
        }
    }
}
