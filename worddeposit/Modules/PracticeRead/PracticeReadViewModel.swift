//
//  PracticeReadModel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 5/3/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

protocol PracticeReadViewModelDelegate: AnyObject {
    func showAlert(title: String, msg: String)
    func showSuccess()
}

final class PracticeReadViewModel {
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
    private var isHint: Bool = false
    
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
    
    func skipAnswer() {
        guard let trainedWord = self.trainedWord else { return }
        guard let skipedIndex = wordsDesk?.firstIndex(matching: trainedWord) else { return }
        self.selectedIndex = skipedIndex
        updateResult(trainedWord, isCorrect: false)
        isHint = true
    }
    
    func updateWordsDesk() {
        guard let wordsDesk = PracticeReadHelper.shared.prepareWords(
                with: self.words ?? [],
                limit: Limits.practiceWords,
                trainedWordIds: correctAnswerIds
        ) else {
            delegate?.showSuccess()
            return
        }
        self.wordsDesk = wordsDesk
        selectedIndex = nil
        isHint = false
    }
    
    func updateAnswer(with selectedIndex: Int) {
        self.selectedIndex = selectedIndex
    }
    
    func getAnswer(from index: Int) -> Answer? {
        guard let selectedIndex = self.selectedIndex else { return nil }
        if selectedIndex == index {
            return getSelectedAnswer(from: index)
        } else {
            return .withoutAnswer
        }
    }
    
    private func getSelectedAnswer(from index: Int) -> Answer? {
        guard let wordsDesk = self.wordsDesk else { return nil }
        let word = wordsDesk[index]
        if word.id == trainedWord?.id {
            return getCorrectAnswer(for: word)
        } else {
            updateResult(word, isCorrect: false)
            return .wrong
        }
    }
    
    private func getCorrectAnswer(for word: Word) -> Answer {
        if isHint {
            updateResult(word, isCorrect: false)
            return .hint
        } else {
            updateResult(word, isCorrect: true)
            return .correct
        }
    }
    
    private func updateResult(_ trainedWord: Word, isCorrect: Bool) {
        if let i = trainedWords.firstIndex(where: { $0.id == trainedWord.id }) {
            updateResult(for: &trainedWords[i], isCorrect: isCorrect)
        } else {
            var word = trainedWord
            updateResult(for: &word, isCorrect: isCorrect)
            trainedWords.append(word)
        }
    }
    
    private func updateResult(for word: inout Word, isCorrect: Bool) {
        if isCorrect == true {
            sesionCorrenctAnswersSum += 1
            word.rightAnswers += 1
        } else {
            sessionWrongAnswersSum += 1
            word.wrongAnswers += 1
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
