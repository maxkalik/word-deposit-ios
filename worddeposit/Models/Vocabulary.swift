import Foundation
import FirebaseFirestore


struct Vocabulary {
    var id: String
    var title: String
    var language: String
//    var words: [Word]
    var isSelected: Bool
    var timestamp: Timestamp
    
    init(
        id: String,
        title: String,
        language: String,
//        words: [Word],
        isSelected: Bool,
        timestamp: Timestamp
    ) {
        self.id = id
        self.title = title
        self.language = language
//        self.words = words
        self.isSelected = isSelected
        self.timestamp = timestamp
    }
    
    init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.title = data["title"] as? String ?? ""
        self.language = data["language"] as? String ?? ""
//        self.words = data["words"] as? [Word] ?? []
        self.isSelected = data["is_selected"] as? Bool ?? false
        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp()
    }
    
    static func modelToData(vocabulary: Vocabulary) -> [String: Any] {
        let data: [String: Any] = [
            "id": vocabulary.id,
            "title": vocabulary.title,
            "language": vocabulary.language,
//            "words": vocabulary.words,
            "is_selected": vocabulary.isSelected,
            "timestamp": vocabulary.timestamp
        ]
        return data
    }
}
