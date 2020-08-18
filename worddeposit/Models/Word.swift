import Foundation
import FirebaseFirestore

struct Word {
    var imgUrl: String
    var example: String
    var translation: String
    var id: String
    var timestamp: Timestamp
    
    init(
        imgUrl: String,
        example: String,
        translation: String,
        id: String,
        timestamp: Timestamp
    ) {
        self.imgUrl = imgUrl
        self.example = example
        self.translation = translation
        self.id = id
        self.timestamp = timestamp
    }
    
    init(data: [String: Any]) {
        self.imgUrl = data["img_url"] as? String ?? ""
        self.example = data["example"] as? String ?? ""
        self.translation = data["translation"] as? String ?? ""
        self.id = data["id"] as? String ?? ""
        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp()
    }
    
    static func modelToData(word: Word) -> [String: Any] {
        let data: [String: Any] = [
            "img_url": word.imgUrl,
            "example": word.example,
            "translation": word.translation,
            "id": word.id,
            "timestamp": word.timestamp
        ]
        return data
    }
}
