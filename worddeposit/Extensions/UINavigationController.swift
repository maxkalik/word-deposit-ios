import UIKit

extension UINavigationController {
    
    func setFont() {
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 17)!]
        self.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 36)!, NSAttributedString.Key.kern: -0.8]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 15)!], for: UIControl.State.normal)
    }
}
