import Foundation
import UIKit

class PracticeTrainers {
    let data = [
        PracticeTrainer(title: "Find Correct Translation", coverImageSource: Images.trainerTranslateToWord, backgroundColor: Colors.lightPurple, controller: Controllers.TrainerWordToTranslate),
        PracticeTrainer(title: "Translate from your language", coverImageSource: Images.trainerWordToTranslate, backgroundColor: Colors.darkBlue, controller: Controllers.TrainerTranslateToWord)
    ]
}
