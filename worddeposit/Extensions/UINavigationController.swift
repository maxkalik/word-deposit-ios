import UIKit

extension UINavigationController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setFont()
    }
    
    func setFont() {
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 22)!, NSAttributedString.Key.kern: -0.8]
        self.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 36)!, NSAttributedString.Key.kern: -0.8]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 14)!, NSAttributedString.Key.kern: -0.5], for: UIControl.State.normal)
    }
}
