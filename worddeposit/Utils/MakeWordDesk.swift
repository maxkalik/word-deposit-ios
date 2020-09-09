//
//  MakeWordDesk.swift
//  worddeposit
//
//  Created by Maksim Kalik on 09/09/2020.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

func makeWordDesk(size: Int, wordsData: [Word], _ result: [Word] = []) -> [Word] {
    var result = result
    if wordsData.count < 5 {
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
