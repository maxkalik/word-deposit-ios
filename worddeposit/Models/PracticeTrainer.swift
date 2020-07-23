import Foundation
import UIKit

struct PracticeTrainer {
    var title: String
    var coverImageSource: String
    var backgroundColor: UIColor
    var controller: String
    
    init(
        title: String = "",
        coverImageSource: String = "",
        backgroundColor: UIColor = UIColor.white,
        controller: String
    ) {
        self.title = title
        self.coverImageSource = coverImageSource
        self.backgroundColor = backgroundColor
        self.controller = controller
    }
}
