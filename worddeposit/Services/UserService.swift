import Foundation
import Firebase
import FirebaseAuth
// import FirebaseStorage

final class UserService {
    
    static let shared = UserService() // global constant
    
    // Variables
    private(set) var user = User()
    private(set) var vocabularies = [Vocabulary]()
    private(set) var words = [Word]() // did set should triger updating words amount
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
    
    func logout(complition: @escaping () -> Void) {
        do {
            try auth.signOut()
            complition()
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
            return
        }
    }
    
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
        // what if userid is empty?
        vocabulariesRef = userRef.collection("vocabularies")
        vocabulariesRef.order(by: "timestamp", descending: true).getDocuments { (snapshot, error) in
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
    
    func getAmountOfWordsFrom(vocabulary: Vocabulary, complition: @escaping (Int) -> Void) {
        let ref = vocabulariesRef.document(vocabulary.id)
        let wordsRef = ref.collection("words")
        wordsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                guard let snap = snapshot else { return }
                
                // update vocabulary words amount
                if vocabulary.wordsAmount != snap.count {
                    ref.updateData(["words_amount": snap.count]) { error in
                        if let error = error {
                            debugPrint(error.localizedDescription)
                            return
                        }
                        complition(snap.count)
                    }
                } else {
                    complition(snap.count)
                }
            }
        }
    }
    
    func getCurrentVocabulary() {
        // here should be checking if array is not empty then check if any vocabulary is Selected if not turn on and update
        let index = self.vocabularies.firstIndex { vocabulary -> Bool in
            return vocabulary.isSelected
        }
        guard let i = index else { return }
        self.currentVocabulary = self.vocabularies[i]
        self.vocabularyRef = self.vocabulariesRef.document(self.vocabularies[i].id)
    }
    
    func fetchWords(vocabularyId: String? = nil, complition: @escaping ([Word]) -> Void) {
        self.wordsRef = vocabularyRef.collection("words")
        let ref = wordsRef.order(by: "timestamp", descending: true)
        if self.currentVocabulary != nil {
            ref.getDocuments { (snapshot, error) in
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
    
    // MARK: - Methods - SET
    
    func setVocabulary(_ vocabulary: Vocabulary, complition: @escaping (String) -> Void) {
        // creating new id
        var vocabulary = vocabulary
        let ref = vocabulariesRef.document()
        vocabulary.id = ref.documentID
        
        let data = Vocabulary.modelToData(vocabulary: vocabulary)
        ref.setData(data) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            self.vocabularies.append(vocabulary)
            complition(vocabulary.id)
        }
    }
    
    func setWord(
        imageData: Data? = nil,
        example: String,
        translation: String,
        description: String? = nil,
        complition: @escaping (Word) -> Void
    ) {
        let ref = wordsRef.document()
        
        var word: Word = Word.init(
            imgUrl: "",
            example: example,
            translation: translation,
            description: description ?? "",
            id: ref.documentID,
            rightAnswers: 0,
            wrongAnswers: 0,
            timestamp: Timestamp()
        )
        
        if imageData != nil {
            setWordImage(data: imageData, id: word.id) { url in
                word.imgUrl = url.absoluteString
                self.setWordData(word, to: ref) {
                    complition(word)
                }
            }
        } else {
            setWordData(word, to: ref) {
                complition(word)
            }
        }
    }
    
    private func setWordData(_ word: Word, to ref: DocumentReference, complition: @escaping () -> Void) {
        let data = Word.modelToData(word: word)
        ref.setData(data) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            self.words.insert(word, at: 0)
            complition()
        }
    }
    
    func setWordImage(data: Data?, id: String, complition: @escaping (URL) -> Void) {
        guard let vocabulary = currentVocabulary, let data = data else { return }
        let ref: StorageReference = Storage.storage().reference().child("/\(user.id)/\(vocabulary.id)/\(id).jpg")
        let metadata: StorageMetadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        ref.putData(data, metadata: metadata) { (storageMetadata, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            ref.downloadURL { (url, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }
                guard let url = url else { return }
                complition(url)
            }
        }
    }
    
    // MARK: - Methods - UPDATE
    
    // Updating Profile
    
    func updateUser(_ user: User, complition: (() -> Void)? = nil) {
        let data = User.modelToData(user: user)
        userRef.updateData(data) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            self.user = user
            complition?()
        }
    }
    
    // Updating Vocabularies
    
    func switchSelectedVocabulary(from: Vocabulary, to: Vocabulary, complition: @escaping () -> Void) {
        let batch = db.batch()
        
        // TODO: - should be rewrite
        
        // let lhVocabularyRef = db.collection("users").document(user.id).collection("vocabularies")
        // update left hand vocabulary
        let lhVocabularyRef = vocabulariesRef.document(from.id)
        batch.updateData(["is_selected" : false], forDocument: lhVocabularyRef)
        // update right hand vocabulary
        let rhVocabularyRef = vocabulariesRef.document(to.id)
        batch.updateData(["is_selected" : true], forDocument: rhVocabularyRef)
        batch.commit() { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            } else {
                self.updateLocal(vocabularies: [from, to])
                complition()
            }
        }
    }
    
    func updateVocabulary(_ vocabulary: Vocabulary, complition: ((Int) -> Void)? = nil) {
        // what if vocabulariesRef is nil?
        // what if we can pass an array with what we want update particularly?
        let ref: DocumentReference = vocabulariesRef.document(vocabulary.id)
        let data = Vocabulary.modelToData(vocabulary: vocabulary)
        ref.updateData(data) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            // probably we can get this index from the didSelectRow
            if let index: Int = self.vocabularies.firstIndex(matching: vocabulary) {
                if !self.vocabularies[index].isSelected {
                    self.vocabularies[index] = vocabulary
                    complition?(index)
                }
            }
        }
    }
    
    func updateVocabularies(_ vocabularies: [Vocabulary], complition: @escaping () -> Void) {
        let batch = db.batch()
        // var updatedVocabularyRef: DocumentReference
        vocabularies.forEach { vocabulary in
            let ref = vocabulariesRef.document(vocabulary.id)
            let data = Vocabulary.modelToData(vocabulary: vocabulary)
            batch.updateData(data, forDocument: ref)
        }
        batch.commit() { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            } else {
                self.updateLocal(vocabularies: vocabularies)
                complition()
            }
        }
    }
    
    private func updateLocal(vocabularies: [Vocabulary]) {
        // TODO: - try to find algorithm to check difference and update array of vocabularies
        vocabularies.forEach { updatedVocabulary in
            for i in 0..<self.vocabularies.count {
                if self.vocabularies[i].id == updatedVocabulary.id {
                    self.vocabularies[i] = updatedVocabulary
                }
            }
        }
    }
    
    private func updateLocal(words: [Word]) {
        words.forEach { updatedWord in
            for i in 0..<self.words.count {
                if self.words[i].id == updatedWord.id {
                    self.words[i] = updatedWord
                }
            }
        }
    }
    
    // Updating Words
    
    func updateWords(_ words: [Word], complition: @escaping () -> Void) {
        let batch = db.batch()
        words.forEach { word in
            let ref = wordsRef.document(word.id)
            let data = Word.modelToData(word: word)
            batch.updateData(data, forDocument: ref)
        }
        batch.commit() { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            } else {
                self.updateLocal(words: words)
                complition()
            }
        }
    }
    
    func updateAnswersScore(_ words: [Word], complition: @escaping () -> Void) {
        let batch = db.batch()
        words.forEach { word in
            let ref = wordsRef.document(word.id)
            batch.updateData(["right_answers" : word.rightAnswers, "wrong_answers" : word.wrongAnswers], forDocument: ref)
        }
        batch.commit() { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            } else {
                self.updateLocal(words: words)
                complition()
            }
        }
    }
    
    func updateWord(_ word: Word, complition: ((Int) -> Void)? = nil) {
        let ref = wordsRef.document(word.id)
        let data = Word.modelToData(word: word)
        ref.updateData(data) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            if let index: Int = self.words.firstIndex(matching: word) {
                self.words[index] = word
                complition?(index)
            }
        }
    }
    
    func updateWordImageUrl(_ word: Word, complition: @escaping () -> Void) {
        let ref = wordsRef.document(word.id)
        print(word)
        ref.updateData(["img_url" : word.imgUrl]) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            if let index: Int = self.words.firstIndex(matching: word) {
                self.words[index].imgUrl = word.imgUrl
                complition()
            }
        }
    }
    
    // MARK: - Methods - REMOVE
    
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
                    self.removeWordImageFrom(vocabularyId: vocabulary.id, wordId: word.id)
                }
            }
        }
    }
    
    func removeWord(_ word: Word, complition: @escaping () -> Void) {
        let ref: DocumentReference = wordsRef.document(word.id)
        ref.delete { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let index = self.words.firstIndex(matching: word) else { return }
            self.words.remove(at: index)
            
            if word.imgUrl.isNotEmpty {
                self.removeWordImageFrom(vocabularyId: self.currentVocabulary!.id, wordId: word.id) {
                    complition()
                }
            } else {
                complition()
            }
        }
    }
    
    func removeWordImageFrom(vocabularyId: String, wordId: String, complition: (() -> Void)? = nil ) {
        let ref = self.storage.reference()
        ref.child("/\(self.user.id)/\(vocabularyId)/\(wordId).jpg").delete { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            complition?()
        }
    }
}
