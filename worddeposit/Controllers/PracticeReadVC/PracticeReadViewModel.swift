//
//  PracticeReadModel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 5/3/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

class PracticeReadModel {
    
    var trainedWord: Word?
    var wordsDesk = [Word]()
    var trainedWords = [Word]()
    var selectedIndex: Int?
    var isSelected = false
    
    var correctAnswerIds = Set<String>()
    var sesionCorrenctAnswersSum = 0 {
        didSet {
            guard let word = trainedWord else { return }
            if !correctAnswerIds.contains(word.id) { correctAnswerIds.insert(word.id) }
        }
    }
    
    var sessionWrongAnswersSum = 0
    
    // MARK: - methods
    
    private func setupTrainedWord() {
        let filteredWordDesk = wordsDesk.filter { !correctAnswerIds.contains($0.id) }
        trainedWord = filteredWordDesk.randomElement()
    }
    
    func getWordDesk() { }
    func getTrainedWord() { }
    
    func skipAnswer() -> Int? {
        guard let index = wordsDesk.firstIndex(matching: trainedWord!) else { return nil }
        getResult(trainedWord!, answer: false)
        updateScreen()
        return index
    }
    func finish() { }
    func selectAnswer(_ index: Int) { }
    
    func updateScreen(with selectedIndex: Int? = nil) {
        self.selectedIndex = self.selectedIndex == selectedIndex ? nil : selectedIndex
        isSelected = true
    }
    
    func updateUI() {
        selectedIndex = nil
        isSelected = false

        setupTrainedWord()
    }
    
    func getResult(_ trainedWord: Word, answer: Bool) {
        PracticeReadHelper.shared.getResult(trainedWord, &trainedWords, answer: answer, &sesionCorrenctAnswersSum, &sessionWrongAnswersSum)
    }
    
    func getGeneralResult() -> Result {
        return Result(wordsAmount: trainedWords.count, answerCorrect: sesionCorrenctAnswersSum, answerWrong: sessionWrongAnswersSum)
    }
}

struct Result {
    let wordsAmount: Int
    let answerCorrect: Int
    let answerWrong: Int
}
