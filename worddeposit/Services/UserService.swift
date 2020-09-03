import Foundation
import Firebase
import FirebaseAuth
// import FirebaseStorage

final class UserService {
    
    static let shared = UserService() // global constant
    
    // Variables
    private(set) var user = User()
    private(set) var vocabularies = [Vocabulary]()
    private(set) var words = [Word]()
    private(set) var currentVocabularyId: String?
    
    // References
    private var userRef: DocumentReference!
    private var vocabulariesRef: CollectionReference!
    private var vocabularyRef: DocumentReference!
    private var wordsRef: CollectionReference!
    
    // Listeners
    private var auth: Auth! = Auth.auth()
    private var db: Firestore! = Firestore.firestore()
    
    private init() {} // original singleton pattern difinition
    
    // MARK: - Methods
    
    func fetchCurrentUser(complition: @escaping (User) -> Void) {
        guard let currentUser = auth.currentUser else { return }
        userRef = self.db.collection("users").document(currentUser.uid)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            if let document = document, document.exists {
                guard let data = document.data() else { return }
                self.user = User.init(data: data)
                complition(self.user)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func fetchVocabularies(complition: @escaping ([Vocabulary]) -> Void) {
        if user.id.isEmpty {
            print("user id is empty")
        }
        vocabulariesRef = userRef.collection("vocabularies")
        vocabulariesRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting vocabularies: \(error)")
                return
            } else {
                self.vocabularies.removeAll()
                guard let documents = snapshot?.documents else { return }
                for document in documents {
                    let data = document.data()
                    let vocabulary = Vocabulary.init(data: data)
                    self.vocabularies.append(vocabulary)
                }
                complition(self.vocabularies)
            }
        }
    }
    
    func getCurrentVocabulary() {
        let index = self.vocabularies.firstIndex { vocabulary -> Bool in
            return vocabulary.isSelected
        }
        guard let i = index else { return }
        let curVocabularyId = self.vocabularies[i].id
        self.currentVocabularyId = curVocabularyId
        self.vocabularyRef = self.vocabulariesRef.document(curVocabularyId)
    }
    
    func fetchWords(vocabularyId: String? = nil, complition: @escaping ([Word]) -> Void) {
        self.wordsRef = vocabularyRef.collection("words")
        if vocabularyId != nil || ((self.currentVocabularyId?.isNotEmpty) != nil) {
            self.wordsRef.getDocuments { (snapshot, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }
                self.words.removeAll()
                guard let documents = snapshot?.documents else { return }
                for document in documents {
                    let data = document.data()
                    let word = Word.init(data: data)
                    self.words.append(word)
                }
                complition(self.words)
            }
        }
    }
}
