//  Created by Maksim Kalik on 7/11/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.

import UIKit

protocol BaseViewControllerDelegate: AnyObject {
    func keyboardDidShow()
    func keyboardDidHide()
    func messageViewButtonPressed()
}

extension BaseViewControllerDelegate {
    func keyboardDidShow() {}
    func keyboardDidHide() {}
    func messageViewButtonPressed() {}
}

class BaseViewController: UIViewController {

    private var messageView = MessageView()
    var activityIndicator = ProgressHUD()
    private(set) var keyboardHeight: CGFloat = 0
    private(set) var isKeyboardShowing = false
    
    weak var baseViewControllerDelegate: BaseViewControllerDelegate?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        setupMessageView()
        view.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if isKeyboardShowing { return }
        isKeyboardShowing = true
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = keyboardFrame.cgRectValue.height
            baseViewControllerDelegate?.keyboardDidShow()
        }
    }
    
    @objc func keyboardWillHide() {
        if !isKeyboardShowing { return }
        isKeyboardShowing = false
        baseViewControllerDelegate?.keyboardDidHide()
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
        activityIndicator.hide()
    }
    
    private func setupMessageView() {
        view.addSubview(messageView)
        messageView.center = view.center
        messageView.hide()
    }
    
    func showMessageView(title text: String, buttonTitle: String) {
        messageView.setTitles(messageTxt: text, buttonTitle: buttonTitle)
        messageView.onPrimaryButtonTap { [weak self] in
            guard let self = self else { return }
            self.baseViewControllerDelegate?.messageViewButtonPressed()
        }
        messageView.show()
    }
    
    func hideMessage() {
        messageView.hide()
    }
    
    func showAlert(title: String, msg: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        present(alert, animated: true, completion: nil)
    }
}
