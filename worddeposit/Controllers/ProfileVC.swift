import UIKit
import Firebase

class ProfileVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showLoginVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(identifier: "login")
        self.view.window?.rootViewController = loginVC
        self.view.window?.makeKeyAndVisible()
    }
    
    @IBAction func onSignOutBtnPress(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            // clear all listeners and ui
            showLoginVC()
        } catch {
            simpleAlert(title: "Error", msg: error.localizedDescription)
            debugPrint(error.localizedDescription)
        }
    }
}
