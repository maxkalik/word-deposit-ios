import UIKit

class ForgotPasswordVC: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackViewCenterY: NSLayoutConstraint!
    
    // Custom
    private var isKeyboardShowing = false
    private var keyboardHeight: CGFloat!
    
    // MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    var progressHUD = ProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        cancelButton.alpha = 0
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = keyboardFrame.cgRectValue.height
            
            // Using centerY constrains and changing it allow to save the position of the stackview at the center
            // even if we accidently touch (and drag) uiViewController.
             UIView.animate(withDuration: 0.3) {
                self.stackViewCenterY.constant -= (self.keyboardHeight - self.stackView.frame.size.height)
                self.view.layoutIfNeeded()
             }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        // check if keyboard already is on the screen
        if !isKeyboardShowing { return }
        isKeyboardShowing = false
        
        titleLabel.alpha = 1
        cancelButton.alpha = 1
        
        self.stackView.frame.origin.y += (keyboardHeight - self.stackView.frame.height)
        
         UIView.animate(withDuration: 0.3) {
            self.stackViewCenterY.constant += (self.keyboardHeight - self.stackView.frame.size.height)
            self.view.layoutIfNeeded()
         }
    }
    
    // MARK: - Methods
    
    // MARK: - IBActions
    @IBAction func onResetPasswordBtnPress(_ sender: UIButton) {
        guard let email = emailTextField.text, email.isNotEmpty else { return }
        
        progressHUD.show()
        
        UserService.shared.resetPassword(withEmail: email) { error in
            self.progressHUD.hide()
            if let error = error {
                UserService.shared.auth.handleFireAuthError(error, viewController: self)
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onCancelBtnPress(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
