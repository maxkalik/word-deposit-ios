import Foundation
import UIKit

//enum PracticeType {
//    case readWordToTranslate
//    case readTranslateToWord
//}

struct PracticeTrainer {
    var title: String
    var coverImageSource: String
    var backgroundColor: UIColor
    var type: PracticeType
    
    init(
        title: String = "",
        coverImageSource: String = "",
        backgroundColor: UIColor = UIColor.white,
        type: PracticeType
    ) {
        self.title = title
        self.coverImageSource = coverImageSource
        self.backgroundColor = backgroundColor
        self.type = type
    }
}
