import UIKit

extension UINavigationController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont(name: Fonts.medium, size: 16)!,
             NSAttributedString.Key.kern: -0.8
            ], for: UIControl.State.normal
        )

        setup(isClear: false)
    }
    
    func setup(isClear: Bool) {
        let navBarAppearance = UINavigationBarAppearance()
        let buttonAppearance = UIBarButtonItemAppearance()
        
        // Chage background color for top navigation view
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.shadowColor = .clear
        navBarAppearance.shadowImage = UIImage()
        navBarAppearance.backgroundColor = isClear ? UIColor.clear : Colors.silver
        
        // Small title
        navBarAppearance.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 22)!,
            NSAttributedString.Key.kern: -0.8
        ]
        
        // Large title
        navBarAppearance.largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 36)!,
            NSAttributedString.Key.kern: -0.8
        ]
        
        // Button titles
        buttonAppearance.normal.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 16)!,
            NSAttributedString.Key.kern: -0.8
        ]
        navBarAppearance.buttonAppearance = buttonAppearance
        
        navigationBar.standardAppearance = navBarAppearance
        navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    func setStatusBar() {
        // chnage here
    }
}
