import UIKit

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
    
    var email: String!
    var firstName: String!
    var lastName: String!
    weak var delegate: UserInfoTVCDelegate?
    
    private var progressHUD = ProgressHUD()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstNameTextField.addTarget(self, action: #selector(userNameDidChange), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(userNameDidChange), for: .editingChanged)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        firstNameTextField.removeTarget(self, action: #selector(userNameDidChange), for: .editingChanged)
        lastNameTextField.removeTarget(self, action: #selector(userNameDidChange), for: .editingChanged)
    }
    
    // MARK: - @objc Methods
    
    @objc func userNameDidChange(_ textField: CellTextField) {
        guard let first = firstNameTextField.text, let last = lastNameTextField.text else { return }
        if first.isNotEmpty && first != firstName || last.isNotEmpty && last != lastName {
            doneButton.isEnabled = true
        }
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // MARK: - Methods
    
    private func setupUI() {
        firstNameTextField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        lastNameTextField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        firstNameTextField.text = firstName
        lastNameTextField.text = lastName
        doneButton.isEnabled = false
        view.superview?.addSubview(progressHUD)
    }
    
    // MARK: - IBActions
    
    @IBAction func doneTouched(_ sender: UIBarButtonItem) {
        guard let first = firstNameTextField.text, let last = lastNameTextField.text else { return }
        delegate?.updateUserInfo(firstName: first, lastName: last)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetPasswordTouched(_ sender: UIButton) {
        progressHUD.show()
        UserService.shared.resetPassword(withEmail: email) { error in
            self.progressHUD.hide()
            if let error = error {
                UserService.shared.auth.handleFireAuthError(error, viewController: self)
                return
            }
            self.simpleAlert(title: "Password", msg: "Password reset success")
        }
    }
    
    @IBAction func deleteAccountTouched(_ sender: UIButton) {
        progressHUD.show()
        let alert = UIAlertController(title: "Are you sure?", message: "If you are sure your account, all vocabularies and words will be removed permanently", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Remove", style: .default, handler: { (action) in
            UserService.shared.removeAccountData() { error in
                self.progressHUD.hide()
                if let error = error {
                    UserService.shared.db.handleFirestoreError(error, viewController: self)
                    return
                }
                UserService.shared.deleteAccount { error in
                    self.progressHUD.hide()
                    if let error = error {
                        UserService.shared.auth.handleFireAuthError(error, viewController: self)
                        return
                    }
                    showLoginVC(view: self.view)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension UserInfoTVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        TextFieldLimit.checkMaxLength(textField, range: range, string: string, limit: Limits.vocabularyTitle)
    }
}
