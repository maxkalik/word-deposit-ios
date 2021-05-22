//
//  PracticeReadHelper.swift
//  worddeposit
//
//  Created by Maksim Kalik on 4/17/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit
import Kingfisher

final class PracticeReadHelper {
    static var shared = PracticeReadHelper()
    private init() {}
    
    func transofrmOnScroll(wordImage: inout RoundedImageView, with offset: CGPoint) {
        if offset.y < 0.0 {
            wordImage.layer.transform = CATransform3DIdentity
        } else {
            let scaleFactor = 1 + (-1 * offset.y / (wordImage.frame.size.height / 2))
            var transform = CATransform3DTranslate(CATransform3DIdentity, 0, (offset.y), 0)
        
            if scaleFactor >= 0.5 {
                transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1)
                wordImage.layer.transform = transform
                wordImage.layer.cornerRadius = (Radiuses.large + offset.y / 2)
            }
        }
    }
    
    func getResult(_ trainedWord: Word, _ trainedWords: inout [Word], answer: Bool, _ sessionRightAnswersSum: inout Int, _ sessionWrongAnswersSum: inout Int) {
        if let i = trainedWords.firstIndex(where: { $0.id == trainedWord.id }) {
            if answer == true {
                sessionRightAnswersSum += 1
                trainedWords[i].rightAnswers += 1
            } else {
                sessionWrongAnswersSum += 1
                trainedWords[i].wrongAnswers += 1
            }
        } else {
            var word = trainedWord
            if answer == true {
                sessionRightAnswersSum += 1
                word.rightAnswers += 1
            } else {
                sessionWrongAnswersSum += 1
                word.wrongAnswers += 1
            }
            trainedWords.append(word)
        }
    }
    
    func setupImage(_ image: inout RoundedImageView, for trainedWord: Word?) {
        guard let word = trainedWord else { return }
        if let url = URL(string: word.imgUrl) {
            image.isHidden = false
            image.kf.indicatorType = .activity
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
            let imgRecourse = ImageResource(downloadURL: url, cacheKey: word.imgUrl)
            image.kf.setImage(with: imgRecourse, options: options)
        } else {
            image.isHidden = true
        }
    }
    
    
    var leftBarButtonHandler: (() -> Void)?
    var rightBarButtonHandler: (() -> Void)?
    
    func setupNavBarLeft(_ handler: (() -> Void)? = nil) -> UIBarButtonItem {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
        let imageView = UIImageView(frame: CGRect(x: 14, y: 10, width: 24, height: 24))
        if let imgBackArrow = UIImage(named: "finish") {
            let plainImage = imgBackArrow.withRenderingMode(.alwaysOriginal)
            imageView.image = plainImage
        }
        view.addSubview(imageView)

        let backTap = UITapGestureRecognizer(target: self, action: #selector(onTapLeftBarItem))
        view.addGestureRecognizer(backTap)

        self.leftBarButtonHandler = handler
        return UIBarButtonItem(customView: view)
    }
    
    func setupNavBarRight(_ handler: (() -> Void)? = nil) -> UIBarButtonItem {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 24, height: 24))
        if let imgQuestion = UIImage(named: "question") {
            let plainImage = imgQuestion.withRenderingMode(.alwaysOriginal)
            imageView.image = plainImage
        }
        view.addSubview(imageView)
        
        let skipTap = UITapGestureRecognizer(target: self, action: #selector(onTapRightBarItem))
        view.addGestureRecognizer(skipTap)
        self.rightBarButtonHandler = handler
        
        return UIBarButtonItem(customView: view)
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
    
    func prepareWords(with words: [Word], trainedWordIds: Set<String>? = nil) -> [Word]? {
        let leftWordsCount = words.count - Int(trainedWordIds?.count ?? 0)
        var wordDesk = [Word]()
        let filteredWordsFromVocabulary = words.filter {
            guard let ids = trainedWordIds else { return true }
            return !ids.contains($0.id)
        }
        if leftWordsCount <= 4 {
            let trainedWords = words.filter {
                guard let ids = trainedWordIds else { return true }
                return ids.contains($0.id)
            }
            
            wordDesk = makeWordDesk(size: 5 - leftWordsCount, wordsData: trainedWords)
            let restArr = makeWordDesk(size: leftWordsCount, wordsData: filteredWordsFromVocabulary)
            wordDesk.append(contentsOf: restArr)
        } else {
            wordDesk = makeWordDesk(size: 5, wordsData: filteredWordsFromVocabulary)
        }
        
        if leftWordsCount == 0 {
            return nil
        } else {
            return wordDesk
        }
    }
    
    @objc private func onTapLeftBarItem() {
        leftBarButtonHandler?()
    }
    
    @objc private func onTapRightBarItem() {
        rightBarButtonHandler?()
    }
}
