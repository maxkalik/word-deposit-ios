import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
    
    // MARK: - Outlets
    
    // Views
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackViewCenterY: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    
    // Text fields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Buttons
    @IBOutlet weak var loginButton: RoundedButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    // Custom
    private var progressHUD = ProgressHUD()
    private var isKeyboardShowing = false
    private var keyboardHeight: CGFloat!
    
    // MARK: - Instances
    
    private var auth: Auth!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        auth = Auth.auth()
        
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
    private func showHomeVC() {
        let storyboard = UIStoryboard(name: Storyboards.Home, bundle: nil)
        let homeViewController = storyboard.instantiateViewController(identifier: Storyboards.Home) as? UITabBarController
        self.view.window?.rootViewController = homeViewController
        self.view.window?.makeKeyAndVisible()
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
    @IBAction func onSignInBtnPress(_ sender: Any) {
        progressHUD.show()
        guard let email = emailTextField.text, email.isNotEmpty,
              let password = passwordTextField.text, password.isNotEmpty else {
                simpleAlert(title: "Error", msg: "Please fill out all fields")
                progressHUD.hide()
                return
        }
        
        auth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.simpleAlert(title: "Error", msg: error.localizedDescription)
                //TODO: - Check infinite loading
                self?.progressHUD.hide()
                return
            }
            self?.progressHUD.hide()
            self?.showHomeVC()
        }
    }
}
