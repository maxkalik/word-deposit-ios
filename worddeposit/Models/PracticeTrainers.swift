import Foundation
import UIKit

struct PracticeTrainers {
    let data = [
        PracticeTrainer(
            title: "Find Correct Translation",
            coverImageSource: Images.trainerTranslateToWord,
            backgroundColor: Colors.lightPurple,
            type: .readWordToTranslate
        ),
        PracticeTrainer(
            title: "Translate from your language",
            coverImageSource: Images.trainerWordToTranslate,
            backgroundColor: Colors.darkBlue,
            type: .readTranslateToWord
        )
    ]
}
