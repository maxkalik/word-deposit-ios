import Foundation

struct Word {
    var imgUrl: String
    var example: String
    var translation: String
    var id: String
    
    init(
        imgUrl: String,
        example: String,
        translation: String,
        id: String
    ) {
        self.imgUrl = imgUrl
        self.example = example
        self.translation = translation
        self.id = id
    }
    
    init(data: [String: Any]) {
        self.imgUrl = data["imgUrl"] as? String ?? ""
        self.example = data["example"] as? String ?? ""
        self.translation = data["translation"] as? String ?? ""
        self.id = data["id"] as? String ?? ""
    }
    
    static func modelToData(word: Word) -> [String: Any] {
        let data: [String: Any] = [
            "imgUrl": word.imgUrl,
            "example": word.example,
            "translation": word.translation,
            "id": word.id
        ]
        return data
    }
}
