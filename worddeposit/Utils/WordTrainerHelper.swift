//
//  MakeWordDesk.swift
//  worddeposit
//
//  Created by Maksim Kalik on 09/09/2020.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

class WordTrainerHelper {
    var words: [Word]
    var trainedWords = [Word]()
    var trainedWord: Word?
    var rightAnswers = Set<String>()
    var selectedIndex: Bool?
    
    var desk: [Word]?
    
    init(words: [Word]) {
        self.words = words
    }

    func makeDesk(size: Int, _ result: [Word] = []) -> [Word] {
        var result = result
        if words.isEmpty { return result }
        var count = size
        if count <= 0 { return result.shuffled() }
        guard let random = words.randomElement() else {
          return makeDesk(size: count, result)
        }
        if !result.contains(random) {
            result.append(random)
            count -= 1
        }
        return makeDesk(size: count, result)
    }
}

func makeWordDesk(size: Int, wordsData: [Word], _ result: [Word] = []) -> [Word] {
    var result = result
    if wordsData.isEmpty {
        return result
    }
    var tmpCount = size
    if tmpCount <= 0 {
        return result.shuffled()
    }
    let randomWord: Word = wordsData.randomElement() ?? wordsData[0]
    if !result.contains(where: { $0.id == randomWord.id }) {
        result.append(randomWord)
        tmpCount -= 1
    }
    return makeWordDesk(size: tmpCount, wordsData: wordsData, result)
}
