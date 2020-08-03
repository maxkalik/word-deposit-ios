import Foundation
import FirebaseFirestore


struct Vocabulary {
    var id: String
    var title: String
    var language: String
    var words: [Word]
    var timestamp: Timestamp
    
    init(
        id: String,
        title: String,
        language: String,
        words: [Word],
        timestamp: Timestamp
    ) {
        self.id = id
        self.title = title
        self.language = language
        self.words = words
        self.timestamp = timestamp
    }
    
    init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.title = data["title"] as? String ?? ""
        self.language = data["language"] as? String ?? ""
        self.words = data["words"] as? [Word] ?? []
        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp()
    }
    
    static func modelToData(vocabulary: Vocabulary) -> [String: Any] {
        let data: [String: Any] = [
            "id": vocabulary.id,
            "title": vocabulary.title,
            "language": vocabulary.language,
            "words": vocabulary.words,
            "timestamp": vocabulary.timestamp
        ]
        return data
    }
}
