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
    private var vocabulariewsRef: CollectionReference!
    private var wordsRef: CollectionReference!
    
    // Listeners
    private var auth: Auth! = Auth.auth()
    private var db: Firestore! = Firestore.firestore()
    
    private init() {} // original singleton pattern difinition
    
    func getCurrentUser(complition: @escaping (User) -> Void) {
        guard let currentUser = auth.currentUser else { return }
        let userRef = self.db.collection("users").document(currentUser.uid)
        
        
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
    
    func getVocabularies(complition: @escaping ([Vocabulary]) -> Void) {
        if user.id.isEmpty {
            print("user id is empty")
        }
        vocabulariewsRef = userRef.collection("vocabularies")
        vocabulariewsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting vocabularies: \(error)")
                return
            } else {
                for document in snapshot!.documents {
                    let data = document.data()
                    let vocabulary = Vocabulary.init(data: data)
                    self.vocabularies.append(vocabulary)
                    complition(self.vocabularies)
                }
            }
        }
    }
    
    func getCurrentVocabulary() {
        let index = self.vocabularies.firstIndex { vocabulary -> Bool in
            return vocabulary.isSelected
        }
        guard let i = index else { return }
        self.currentVocabularyId = self.vocabularies[i].id
    }
}
