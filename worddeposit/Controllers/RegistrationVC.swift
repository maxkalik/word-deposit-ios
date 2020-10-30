import UIKit

class RegistrationVC: UIViewController {
    
    // MARK: - IBOutlets
    
    // Views
    @IBOutlet weak var signupImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: PrimaryButton!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackViewCenterY: NSLayoutConstraint!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Custom
    var progressHUD = ProgressHUD()
    private var isKeyboardShowing = false
    private var keyboardHeight: CGFloat!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable login button
        signUpButton.isEnabled = false
        
        // Spinner
        self.view.addSubview(progressHUD)
        
        // Hide keyboard when tapped around if keyboard on the screen
        hideKeyboardWhenTappedAround()
        
        // Visuals
        view.backgroundColor = Colors.yellow        
        titleLabel.textColor = Colors.dark
        
        setNavigationBar()
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
        
        // titleLabel.isHidden = true
        titleLabel.alpha = 0
        hideSecondaryButtons()
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = keyboardFrame.cgRectValue.height
            
            // Using centerY constrains and changing it allow to save the position of the stackview at the center
            // even if we accidently touch (and drag) uiViewController.
            UIView.animate(withDuration: 0.3) { [self] in
                stackViewCenterY.constant -= (keyboardHeight - stackView.frame.size.height / 2) + signupImageView.frame.size.height
                signupImageView.alpha = 0
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
            stackViewCenterY.constant += (keyboardHeight - stackView.frame.size.height / 2) + signupImageView.frame.size.height
            signupImageView.alpha = 1
            view.layoutIfNeeded()
        }
    }
    
    @objc func backToMain() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Methods
    
    private func setNavigationBar() {
        self.navigationItem.setHidesBackButton(true, animated: false)

        let view = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 24, height: 24))

        if let imgBackArrow = UIImage(named: Icons.Back) {
            let tintedImage = imgBackArrow.withRenderingMode(.alwaysTemplate)
            imageView.image = tintedImage
            imageView.tintColor = Colors.dark
        }

        view.addSubview(imageView)

        let backTap = UITapGestureRecognizer(target: self, action: #selector(backToMain))
        view.addGestureRecognizer(backTap)

        let leftBarButtonItem = UIBarButtonItem(customView: view)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    private func validateFields(email: String, password: String) {
        let validator = Validator()
        let validEmail = validator.validate(text: email, with: [.email, .notEmpty])
        let validPassword = validator.validate(text: password, with: [.password, .notEmpty])
        signUpButton.isEnabled = validEmail && validPassword
    }
    
    private func hideSecondaryButtons() {
        loginButton.alpha = 0
    }
    
    private func showSecondaryButtons() {
        loginButton.alpha = 1
    }
    
    private func setupApp() {
        let storyboard = UIStoryboard(name: Storyboards.Home, bundle: nil)
        let homeViewController = storyboard.instantiateViewController(identifier: Storyboards.Home) as? UITabBarController
        self.view.window?.rootViewController = homeViewController
    }
    
    private func showError(_ error: Error) {
        self.simpleAlert(title: "Error", msg: error.localizedDescription)
        self.progressHUD.hide()
        return
    }
    
    // MARK: - IBActions
    
    @IBAction func onSignUpBtnPress(_ sender: UIButton) {
        
        guard let email = emailTextField.text, email.isNotEmpty,
            let password = passwordTextField.text, password.isNotEmpty else { return }
        
        self.progressHUD.show()
        
        UserService.shared.signUp(withEmail: email, password: password) { error in
            self.progressHUD.hide()
            if let error = error {
                UserService.shared.auth.handleFireAuthError(error, viewController: self)
                return
            } else {
                self.setupApp()                
            }
        }
    }
    
    @IBAction func onHaveAccountBtnPress(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
