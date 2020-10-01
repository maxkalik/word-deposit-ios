import UIKit

extension UINavigationController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setup(isClear: false)
    }
    
    func setup(isClear: Bool) {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.shadowColor = .clear
        navBarAppearance.shadowImage = UIImage()
        navBarAppearance.backgroundColor = isClear ? UIColor.clear : Colors.silver
        navBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 22)!, NSAttributedString.Key.kern: -0.8]
        navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 36)!, NSAttributedString.Key.kern: -0.8]
        navigationBar.standardAppearance = navBarAppearance
        navigationBar.scrollEdgeAppearance = navBarAppearance
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 15)!, NSAttributedString.Key.kern: -0.8], for: UIControl.State.normal)
    }
    
    func setStatusBar() {
        // chnage here
    }
}
