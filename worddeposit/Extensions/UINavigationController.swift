import UIKit

extension UINavigationController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setFont()
        setUpNavBar()
    }
    
    func setFont() {
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 22)!, NSAttributedString.Key.kern: -0.8]
        navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 36)!, NSAttributedString.Key.kern: -0.8]
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 14)!, NSAttributedString.Key.kern: -0.5]
    }
    
    func setUpNavBar() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.shadowColor = .clear
        navBarAppearance.shadowImage = UIImage()
        navBarAppearance.backgroundColor = Colors.silver
        navigationBar.standardAppearance = navBarAppearance
        navigationBar.scrollEdgeAppearance = navBarAppearance
    }
}
