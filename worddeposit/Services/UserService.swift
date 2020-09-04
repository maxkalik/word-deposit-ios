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
    private(set) var currentVocabulary: Vocabulary?
    
    // References
    private var userRef: DocumentReference!
    private var vocabulariesRef: CollectionReference! // vocabularies collection
    private var vocabularyRef: DocumentReference! // with vocabulary id
    private var wordsRef: CollectionReference!
    
    // Listeners
    private var auth: Auth = Auth.auth()
    private var db: Firestore = Firestore.firestore()
    private var storage: Storage = Storage.storage()
    
    private init() {} // original singleton pattern difinition
    
    // MARK: - Methods - AUTH
    
    // MARK: - Methods - GET
    
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
        self.currentVocabulary = self.vocabularies[i]
        self.vocabularyRef = self.vocabulariesRef.document(self.vocabularies[i].id)
    }
    
    func fetchWords(vocabularyId: String? = nil, complition: @escaping ([Word]) -> Void) {
        self.wordsRef = vocabularyRef.collection("words")
        if vocabularyId != nil || ((self.currentVocabulary?.id.isNotEmpty) != nil) {
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
    
    // MARK: - Methods - ADD
    
    
    
    // MARK: - Methods - UPDATE
    
    func updateVocabulary(_ vocabulary: Vocabulary, complition: @escaping () -> Void) {
        // what if vocabulariesRef is nil?
        // what if we can pass an array with what we want update particularly?
        let ref: DocumentReference = vocabulariesRef.document(vocabulary.id)
        let data = Vocabulary.modelToData(vocabulary: vocabulary)
        ref.updateData(data) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            complition()
        }
    }
    
    // MARK: - Methods - REMOVE
    
    func removeAllWordImagesFrom(vocabulary: Vocabulary) {
        // what if vocabulariesRef is nil?
        let ref: DocumentReference = vocabulariesRef.document(vocabulary.id)
        // do we need order(by: "img_url")?
        ref.collection("words").order(by: "img_url").getDocuments { (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            guard let documents = snapshot?.documents else { return }
            for document in documents {
                let data = document.data()
                let word = Word.init(data: data)
                if word.imgUrl.isNotEmpty {
                    let storageRef = self.storage.reference()
                    storageRef.child("/\(self.user.id)/\(vocabulary.id)/\(word.id).jpg").delete { (error) in
                        if let error = error {
                            debugPrint(error.localizedDescription)
                            return
                        }
                    }
                }
            }
        }
        
    }
    
    func removeVocabulary(_ vocabulary: Vocabulary, complition: @escaping () -> Void) {
        
        let ref: DocumentReference = vocabulariesRef.document(vocabulary.id)
        
        // check vocabulary have image folder in store
        self.removeAllWordImagesFrom(vocabulary: vocabulary)
        
        // remove vocabulary with words
        ref.delete { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            complition()
        }
    }
}
