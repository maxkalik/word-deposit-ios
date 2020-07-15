import UIKit

protocol UserInfoTVCDelegate: AnyObject {
    func updateUserInfo(firstName: String, lastName: String)
}

class UserInfoTVC: UITableViewController {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var firstNameTextField: CellTextField!
    @IBOutlet weak var lastNameTextField: CellTextField!

    var firstName: String!
    var lastName: String!
    weak var delegate: UserInfoTVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("user info table view")
        firstNameTextField.text = firstName
        lastNameTextField.text = lastName
        doneButton.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        firstNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        firstNameTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        lastNameTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: CellTextField) {
        guard let first = firstNameTextField.text, let last = lastNameTextField.text else { return }
        if first.isNotEmpty && first != firstName || last.isNotEmpty && last != lastName {
            doneButton.isEnabled = true
        }
    }
    
    @IBAction func doneTouched(_ sender: UIBarButtonItem) {
        guard let first = firstNameTextField.text, let last = lastNameTextField.text else { return }
        delegate?.updateUserInfo(firstName: first, lastName: last)
        navigationController?.popViewController(animated: true)
    }
}
