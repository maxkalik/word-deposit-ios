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
    func showAlert(title: String, msg: String)
    func showSuccess()
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
            if !correctAnswerIds.contains(word.id) {
                correctAnswerIds.insert(word.id)
            }
        }
    }
    
    weak var delegate: PracticeReadViewModelDelegate?
    var sessionWrongAnswersSum = 0

    init(practiceType: PracticeType, words: [Word]) {
        self.practiceType = practiceType
        self.words = words
    }
    
    func setupContent() {
        updateWordsDesk()
    }

    private func setupTrainedWord() {
        let filteredWordDesk = wordsDesk?.filter { !correctAnswerIds.contains($0.id) }
        trainedWord = filteredWordDesk?.randomElement()
    }
    
    func getSkipedAnswerIndex() -> Int? {
        guard let index = wordsDesk?.firstIndex(matching: trainedWord!) else { return nil }
        updateResult(trainedWord!, isCorrect: false)
        updateWordsDesk()
        return index
    }
    
    func updateWordsDesk() {
        guard let wordsDesk = PracticeReadHelper.shared.prepareWords(with: self.words ?? [], trainedWordIds: correctAnswerIds) else {
            delegate?.showSuccess()
            return
        }
        self.wordsDesk = wordsDesk
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
                updateResult(word, isCorrect: true)
                return .correct
            } else {
                updateResult(word, isCorrect: false)
                return .wrong
            }
        } else {
            return .withoutAnswer
        }
    }
    
    private func updateResult(_ trainedWord: Word, isCorrect: Bool) {
        if let i = trainedWords.firstIndex(where: { $0.id == trainedWord.id }) {
            if isCorrect == true {
                sesionCorrenctAnswersSum += 1
                trainedWords[i].rightAnswers += 1
            } else {
                sessionWrongAnswersSum += 1
                trainedWords[i].wrongAnswers += 1
            }
        } else {
            var word = trainedWord
            if isCorrect == true {
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
    
    func finishPractice() {
        UserService.shared.updateAnswersScore(trainedWords) { [weak self] error in
            // TODO: loading
            guard let self = self else { return }
            if error != nil {
                self.delegate?.showAlert(title: "Error", msg: "Cannot update answers score")
                return
            }
        }
    }
}
