import UIKit

class RegistrationVC: UIViewController {
    
    // MARK: - IBOutlets
    
    // Views
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
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
        
        // Spinner
        self.view.addSubview(progressHUD)
        
        // Hide keyboard when tapped around if keyboard on the screen
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        progressHUD.hide()
        
        // Keyboard observers - willshow willhide
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - @objc Methods
    
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
            UIView.animate(withDuration: 0.3) {
                self.stackViewCenterY.constant -= (self.keyboardHeight - self.stackView.frame.size.height / 2)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        // check if keyboard already is on the screen
        if !isKeyboardShowing { return }
        isKeyboardShowing = false
        
        titleLabel.alpha = 1
        showSecondaryButtons()
        
        self.stackView.frame.origin.y += (keyboardHeight - self.stackView.frame.height / 2)
        
        UIView.animate(withDuration: 0.3) {
            self.stackViewCenterY.constant += (self.keyboardHeight - self.stackView.frame.size.height / 2)
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Methods
    
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
            let password = passwordTextField.text, password.isNotEmpty else {
                simpleAlert(title: "Error", msg: "Please fill out all fields.")
                return
        }
        self.progressHUD.show()
        
        UserService.shared.signUp(withEmail: email, password: password) { error in
            if let error = error {
                UserService.shared.auth.handleFireAuthError(error, viewController: self)
                self.progressHUD.hide()
                return
            }
            self.progressHUD.hide()
            self.setupApp()
        }
    }
    
    @IBAction func onHaveAccountBtnPress(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
