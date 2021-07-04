//
//  Result.swift
//  worddeposit
//
//  Created by Maksim Kalik on 5/23/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

enum ResultState {
    case lestThan5CorrectWordsAmount
    case smallCorrectWordsAmount
    case moreThan70precentsCorrectWords
    case moreThan90precentsCorrectWords
    case excelentResult
    case normalCorrectWordsAmount
    case lessThan30precentsOfCorrectWords
    case lessThan10precentsOfCorrectWords
    case onlyMistakes
}

struct Result {
    let wordsAmount: Int
    let answerCorrect: Int
    let answerWrong: Int
    let isWordDeskEmpty: Bool
    
    init(wordsAmount: Int,
         answerCorrect: Int,
         answerWrong: Int,
         isWordDeskEmpty: Bool = false
    ) {
        self.wordsAmount = wordsAmount
        self.answerCorrect = answerCorrect
        self.answerWrong = answerWrong
        self.isWordDeskEmpty = isWordDeskEmpty
    }
    
    var state: ResultState {
        switch wordsAmount {
        case 1..<5:
            return .lestThan5CorrectWordsAmount
        case 5..<10:
            return .smallCorrectWordsAmount
        default:
            return getRatio()
        }
    }
    
    private func getRatio() -> ResultState {
        let precentage = getPrecetage()
        switch precentage {
        case 0:
            return .onlyMistakes
        case 1..<10:
            return .lessThan10precentsOfCorrectWords
        case 10..<30:
            return .lessThan30precentsOfCorrectWords
        case 90..<100:
            return .moreThan90precentsCorrectWords
        case 70..<100:
            return .moreThan70precentsCorrectWords
        case 100:
            return .excelentResult
        default:
            return .normalCorrectWordsAmount
        }
    }
    
    private func getPrecetage() -> Int {
        let sum = answerCorrect + answerWrong
        return (answerCorrect * 100) / sum
    }
}
