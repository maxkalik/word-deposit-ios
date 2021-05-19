//
//  PracticeReadModel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 5/3/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

protocol PracticeReadViewModelDelegate: AnyObject {
    func startNextWordLoading()
    func stopNextWordLoading()
}

class PracticeReadViewModel {
    
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
    
    weak var delegate: PracticeReadViewModelDelegate?
    
    var sessionWrongAnswersSum = 0
    
    // MARK: - methods
    
    func viewDidLoad() {
        setupTrainedWord()
    }
    
    func viewWillAppear() {
        setupTrainedWord()
    }
    
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
    
    private func getResult(_ trainedWord: Word, answer: Bool) {
        if let i = trainedWords.firstIndex(where: { $0.id == trainedWord.id }) {
            if answer == true {
                sesionCorrenctAnswersSum += 1
                trainedWords[i].rightAnswers += 1
            } else {
                sessionWrongAnswersSum += 1
                trainedWords[i].wrongAnswers += 1
            }
        } else {
            var word = trainedWord
            if answer == true {
                sesionCorrenctAnswersSum += 1
                word.rightAnswers += 1
            } else {
                sessionWrongAnswersSum += 1
                word.wrongAnswers += 1
            }
            trainedWords.append(word)
        }
    }
    
    func getGeneralResult() -> Result {
        return Result(wordsAmount: trainedWords.count, answerCorrect: sesionCorrenctAnswersSum, answerWrong: sessionWrongAnswersSum)
    }
    
    func startLoading() {
        self.delegate?.startNextWordLoading()
    }
    
    func finishLoading() {
        self.delegate?.stopNextWordLoading()
    }
}

struct Result {
    let wordsAmount: Int
    let answerCorrect: Int
    let answerWrong: Int
}
