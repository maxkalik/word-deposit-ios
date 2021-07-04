//
//  SuccessMessageViewModel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 6/27/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

class SuccessMessageViewModel {
    var result: Result

    init(result: Result) {
        self.result = result
    }
    
    var isModalDismissableOnSwap: Bool {
        return self.result.isWordDeskEmpty
    }
    
    var imageName: String? {
        return getContent().0.rawValue
    }
    
    var title: String {
        return getContent().1
    }
    
    var description: String {
        switch result.wordsAmount {
        case 1:
            return "You trained only 1 word"
        case 2..<10:
            return "You trained only \(result.wordsAmount) words"
        default:
            return result.isWordDeskEmpty
                ? "You trained all words!"
                : "You trained \(result.wordsAmount) words"
        }
    }
    
    var correctWords: String {
        return "Correct: \(String(result.answerCorrect))"
    }
    
    var wrongWords: String {
        return "Wrong: \(String(result.answerWrong))"
    }
    
    private func getContent() -> (SuccessMessageImage, String) {
        switch result.state {
        case .onlyMistakes:
            return (.walking, "Mistakes are ok!")
        case .lestThan5CorrectWordsAmount:
            return (.walking, "You could practice more words")
        case .smallCorrectWordsAmount:
            return (.standing, "Better add more words")
        case .lessThan10precentsOfCorrectWords:
            return (.standing, "You can do better!")
        case .lessThan30precentsOfCorrectWords:
            return (.sitting, "It's not your the best result!")
        case .moreThan70precentsCorrectWords:
            return (.rocker, "You are the rockstar!")
        case .moreThan90precentsCorrectWords, .excelentResult:
            return (.skater, "Excelent")
        default:
            return (.social, "Great!")
        }
    }
}
