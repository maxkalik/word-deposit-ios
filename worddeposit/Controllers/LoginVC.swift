import UIKit

class LoginVC: UIViewController {
    
    // MARK: - Outlets
    
    // Views
    @IBOutlet weak var loginImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackViewCenterY: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    
    // Text fields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Buttons
    @IBOutlet weak var loginButton: PrimaryButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    // Custom
    private var progressHUD = ProgressHUD()
    private var isKeyboardShowing = false
    private var keyboardHeight: CGFloat!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable login button
        loginButton.isEnabled = false
        
        // Spinner
        self.view.addSubview(progressHUD)
        
        // Hide keyboard when tapped around if keyboard on the screen
        hideKeyboardWhenTappedAround()
        
        // Visuals
        view.backgroundColor = Colors.yellow
        titleLabel.textColor = Colors.dark
        
        // Setup Navigation Bar
        navigationController?.setup(isClear: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        progressHUD.hide()
        
        // Keyboard observers - willshow willhide
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        emailTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    // MARK: - @objc Methods
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        validateFields(email: email, password: password)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        // check if keyboard already is on the screen
        if isKeyboardShowing { return }
        isKeyboardShowing = true
        
        titleLabel.alpha = 0
        hideSecondaryButtons()
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = keyboardFrame.cgRectValue.height
            
            // Using centerY constrains and changing it allow to save the position of the stackview at the center
            // even if we accidently touch (and drag) uiViewController.
             UIView.animate(withDuration: 0.3) { [self] in
                stackViewCenterY.constant -= (keyboardHeight - stackView.frame.size.height / 2) + loginImageView.frame.size.height
                loginImageView.alpha = 0
                view.layoutIfNeeded()
             }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        // check if keyboard already is on the screen
        if !isKeyboardShowing { return }
        isKeyboardShowing = false
        
        titleLabel.alpha = 1
        showSecondaryButtons()
        
         UIView.animate(withDuration: 0.3) { [self] in
            stackViewCenterY.constant += (keyboardHeight - stackView.frame.size.height / 2) + loginImageView.frame.size.height
            loginImageView.alpha = 1
            view.layoutIfNeeded()
         }
    }
    
    // MARK: - Methods
    private func validateFields(email: String, password: String) {
        let validator = Validator()
        let validEmail = validator.validate(text: email, with: [.email, .notEmpty])
        let validPassword = validator.validate(text: password, with: [.password, .notEmpty])
        loginButton.isEnabled = validEmail && validPassword
    }
    
    private func showHomeVC() {
        let storyboard = UIStoryboard(name: Storyboards.Home, bundle: nil)
        let homeTabBarController = storyboard.instantiateViewController(identifier: Storyboards.Home) as? UITabBarController
        view.window?.rootViewController = homeTabBarController
        view.window?.makeKeyAndVisible()
    }
    
    private func hideSecondaryButtons() {
        createAccountButton.alpha = 0
        forgotPasswordButton.alpha = 0
    }
    
    private func showSecondaryButtons() {
        createAccountButton.alpha = 1
        forgotPasswordButton.alpha = 1
    }
    
    // MARK: - IBActions
    @IBAction func onSignInBtnPress(_ sender: UIButton) {
        
        guard let email = emailTextField.text, email.isNotEmpty,
              let password = passwordTextField.text, password.isNotEmpty else { return }
        
        dismissKeyboard()
        progressHUD.show()
        
        UserService.shared.signIn(withEmail: email, password: password) { error in
            
            if let error = error {
                self.progressHUD.hide()
                UserService.shared.auth.handleFireAuthError(error, viewController: self)
                return
            }
            
            UserService.shared.fetchCurrentUser { error, user in
                self.progressHUD.hide()
                if let error = error {
                    self.simpleAlert(title: "Error", msg: error.localizedDescription)
                    return
                } else {
                    guard let _ = user else {
                        self.simpleAlert(title: "Error", msg: "User was deleted or not exist. Please register new one")
                        return
                    }
                    self.showHomeVC()
                }
            }
            
        }
    }
}
