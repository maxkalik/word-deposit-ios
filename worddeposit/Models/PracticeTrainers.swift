import Foundation
import UIKit

class PracticeTrainers {
    let data = [
        PracticeTrainer(title: "Find Correct Translation", coverImageSource: Images.trainerTranslateToWord, backgroundColor: #colorLiteral(red: 0.7653821244, green: 0.1509081417, blue: 0.7507963907, alpha: 1), controller: Controllers.TrainerWordToTranslate),
        PracticeTrainer(title: "Translate from your language", coverImageSource: Images.trainerWordToTranslate, backgroundColor: #colorLiteral(red: 0.1705212513, green: 0.06666667014, blue: 1, alpha: 1), controller: Controllers.TrainerTranslateToWord)
    ]
}
