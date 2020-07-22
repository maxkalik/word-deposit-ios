import Foundation
import UIKit

struct Trainer {
    var title: String
    var coverImageSource: String
    var backgroundColor: UIColor
    var viewController: String
    
    init(
        title: String = "",
        coverImageSource: String = "",
        backgroundColor: UIColor = UIColor.white,
        viewController: String
    ) {
        self.title = title
        self.coverImageSource = coverImageSource
        self.backgroundColor = backgroundColor
        self.viewController = viewController
    }
}
