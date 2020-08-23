import Foundation
import FirebaseFirestore

struct Word: Equatable {
    var imgUrl: String
    var example: String
    var translation: String
    var description: String
    var id: String
    var rightAnswers: Int
    var wrongAnswers: Int
    var timestamp: Timestamp
    
    init(
        imgUrl: String,
        example: String,
        translation: String,
        description: String,
        id: String,
        rightAnswers: Int,
        wrongAnswers: Int,
        timestamp: Timestamp
    ) {
        self.imgUrl = imgUrl
        self.example = example
        self.translation = translation
        self.description = description
        self.id = id
        self.rightAnswers = rightAnswers
        self.wrongAnswers = wrongAnswers
        self.timestamp = timestamp
    }
    
    init(data: [String: Any]) {
        self.imgUrl = data["img_url"] as? String ?? ""
        self.example = data["example"] as? String ?? ""
        self.translation = data["translation"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.id = data["id"] as? String ?? ""
        self.rightAnswers = data["right_answers"] as? Int ?? 0
        self.wrongAnswers = data["wrong_answers"] as? Int ?? 0
        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp()
    }
    
    static func modelToData(word: Word) -> [String: Any] {
        let data: [String: Any] = [
            "img_url": word.imgUrl,
            "example": word.example,
            "translation": word.translation,
            "description": word.description,
            "id": word.id,
            "right_answers": word.rightAnswers,
            "wrong_answers": word.wrongAnswers,
            "timestamp": word.timestamp
        ]
        return data
    }
    
    static func == (lhs: Word, rhs: Word) -> Bool {
        return
                lhs.imgUrl == rhs.imgUrl &&
                lhs.example == rhs.example &&
                lhs.translation == rhs.translation &&
                lhs.description == rhs.description &&
                lhs.rightAnswers == rhs.rightAnswers &&
                lhs.wrongAnswers == rhs.wrongAnswers &&
                lhs.id == rhs.id
    }
}
