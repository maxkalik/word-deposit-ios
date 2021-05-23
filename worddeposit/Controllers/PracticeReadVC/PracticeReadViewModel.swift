//
//  PracticeReadModel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 5/3/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

struct Result {
    let wordsAmount: Int
    let answerCorrect: Int
    let answerWrong: Int
}

protocol PracticeReadViewModelDelegate: AnyObject {
    func startNextWordLoading()
    func stopNextWordLoading()
}

class PracticeReadViewModel {
    
    var practiceType: PracticeType
    
    var trainedWord: Word?
    
    var trainedWordTitle: String? {
        switch practiceType {
        case .readWordToTranslate:
            return trainedWord?.example
        case .readTranslateToWord:
            return trainedWord?.translation
        }
    }
    var words: [Word]?
    var wordsDesk: [Word]? {
        didSet {
            setupTrainedWord()
        }
    }
    var trainedWords: [Word] = []
    private var selectedIndex: Int?
    
    var correctAnswerIds = Set<String>()
    var sesionCorrenctAnswersSum = 0 {
        didSet {
            guard let word = trainedWord else { return }
            if !correctAnswerIds.contains(word.id) { correctAnswerIds.insert(word.id) }
        }
    }
    
    weak var delegate: PracticeReadViewModelDelegate?
    
    var sessionWrongAnswersSum = 0
    
    // MARK: - init
    
    init(practiceType: PracticeType, words: [Word]) {
        self.practiceType = practiceType
        self.words = words
        print("**** model init")
    }
    
    func setupContent() {
        updateWordsDesk()
    }
    
    // MARK: - methods
    
    private func setupTrainedWord() {
        let filteredWordDesk = wordsDesk?.filter { !correctAnswerIds.contains($0.id) }
        trainedWord = filteredWordDesk?.randomElement()
    }
    
    func skipAnswer() -> Int? {
        guard let index = wordsDesk?.firstIndex(matching: trainedWord!) else { return nil }
        getResult(trainedWord!, answer: false)
        updateWordsDesk()
        return index
    }
    
    func updateWordsDesk() {
        self.wordsDesk = PracticeReadHelper.shared.prepareWords(with: self.words ?? []) ?? []
        selectedIndex = nil
    }
    
    func updateAnswer(with selectedIndex: Int) {
        self.selectedIndex = selectedIndex
    }
    
    func getAnswer(from index: Int) -> Answer? {
        guard let selectedIndex = self.selectedIndex else { return nil }
        if selectedIndex == index {
            guard let wordsDesk = self.wordsDesk else { return nil }
            let word = wordsDesk[index]
            if word.id == trainedWord?.id {
                return .correct
            } else {
                return .wrong
            }
        } else {
            return .withoutAnswer
        }
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
