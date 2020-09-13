import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

final class UserService {
    
    static let shared = UserService() // global constant
    
    // Variables
    private(set) var user = User()
    private(set) var vocabularies = [Vocabulary]()
    private(set) var words = [Word]() // did set should triger updating words amount
    private(set) var vocabulary: Vocabulary?
    
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
    
    // Sign in
    func signIn(withEmail email: String, password: String, complition: @escaping () -> Void) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            complition()
        }
    }
    
    // Sign up
    func signUp(withEmail email: String, password: String, complition: @escaping () -> Void) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            guard let firUser = result?.user else { return }
            let user = User.init(id: firUser.uid, email: email)
            
            self.setUser(user) {
                complition()
            }
        }
    }
    
    // Reset password
    func resetPassword(withEmail email: String, complition: @escaping () -> Void) {
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            complition()
        }
    }
    
    // Delete account
    func deleteAccount(complition: @escaping () -> Void) {
        guard let currentUser = auth.currentUser else { return }
        currentUser.delete { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            complition()
        }
    }
    
    // Logout
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
    
    // Get current user from database
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
                // TODO: - check if user doesn't exist
                print("Document does not exist")
            }
        }
    }
    
    // Fetch vocabularies
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
    
    // Get amount of words from particular vocabulary
    func getAmountOfWordsFrom(vocabulary: Vocabulary, complition: @escaping (Int) -> Void) {
        let ref = vocabulariesRef.document(vocabulary.id)
        let wordsRef = ref.collection("words")
        wordsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                guard let snap = snapshot else { return }
                
                /// Update vocabulary words amount
                if vocabulary.wordsAmount != snap.count && !vocabulary.isSelected {
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
    
    // Get current vocabulary and set it to the var
    func getCurrentVocabulary() {
        // here should be checking if array is not empty then check if any vocabulary is Selected if not turn on and update
        let index = self.vocabularies.firstIndex { vocabulary -> Bool in
            return vocabulary.isSelected
        }
        guard let i = index else { return }
        self.vocabulary = self.vocabularies[i]
        self.vocabularyRef = self.vocabulariesRef.document(self.vocabularies[i].id)
    }
    
    // Fetch all words from particular vocabulary (id) and complition will take an array of fetched words
    func fetchWords(complition: @escaping ([Word]) -> Void) {
        /// Setup global ref if vocabularyRef has a currenct vocabulary id
        self.wordsRef = vocabularyRef.collection("words")
        let ref = wordsRef.order(by: "timestamp", descending: true)
        if self.vocabulary != nil {
            ref.getDocuments { (snapshot, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }
                /// before apped an array it should be cleaned up
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
    
    // Set up new User to the database
    func setUser(_ user: User, complition: @escaping () -> Void) {
        let ref = db.collection("users").document(user.id)
        let data = User.modelToData(user: user)
        
        ref.setData(data) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            complition()
        }
    }
    
    // Create new vocabulary and set to the the db user.vocabularies/<vocabulary>
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
            self.vocabularies.insert(vocabulary, at: 0)
            complition(vocabulary.id)
        }
    }
    
    // Create new word and set to the db user.vocabularies/vocabulary.words/<word>
    func setWord(
        imageData: Data? = nil,
        example: String,
        translation: String,
        description: String? = nil,
        complition: @escaping (Word) -> Void
    ) {
        /// Creating new document (word) ref
        let ref = wordsRef.document()
        
        /// Creating new word
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
        
        /// Checking if new word has image data
        if imageData != nil {
            /// set image data to the storage
            setWordImage(data: imageData, id: word.id) { url in
                /// Adding img url string to the word instance
                word.imgUrl = url.absoluteString
                /// Setting word data to the db
                self.setWordData(word, to: ref) {
                    complition(word)
                }
            }
        } else {
            /// Setting word data to the db
            setWordData(word, to: ref) {
                complition(word)
            }
        }
    }
    
    // Set word data to the db. Works only with ref
    private func setWordData(_ word: Word, to ref: DocumentReference, complition: @escaping () -> Void) {
        let data = Word.modelToData(word: word)
        ref.setData(data) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            self.words.insert(word, at: 0)
            self.updateAmountOfWords()
            complition()
        }
    }
    
    // Set word image data to the storage user_id/vocabulary_id/word_id.jpg
    func setWordImage(data: Data?, id: String, complition: @escaping (URL) -> Void) {
        guard let vocabulary = self.vocabulary, let data = data else { return }
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
                /// Complition with url argument for setting it to the word data when complite this uploading process
                complition(url)
            }
        }
    }
    
    // MARK: - Methods - UPDATE
    
    // Update user profile
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
    
    // Switch selected vocabulary - updating is_selected property in 2 vocabularies
    func switchSelectedVocabulary(from: Vocabulary, to: Vocabulary, complition: @escaping () -> Void) {
        /// Creating batch for updating in one response
        let batch = db.batch()
        
        /// Taking previous vocabulary and set property is_selected to the false
        let lhVocabularyRef = vocabulariesRef.document(from.id)
        batch.updateData(["is_selected" : false], forDocument: lhVocabularyRef)
        
        /// Taking future vocabulary and set property is_selected to the true
        let rhVocabularyRef = vocabulariesRef.document(to.id)
        batch.updateData(["is_selected" : true], forDocument: rhVocabularyRef)
        
        /// Commiting the batch
        batch.commit() { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            } else {
                /// Updating local array of vocabularies
                self.updateLocal(vocabularies: [from, to])
                complition()
            }
        }
    }
    
    // Update whole vocabulry
    func updateVocabulary(_ vocabulary: Vocabulary, complition: ((Int) -> Void)? = nil) {
        
        // TODO: - could vocabulariesRef be nil?
        // TODO: - what if we can pass an array with what we want update particularly?
        
        /// Taking a ref with a particular vocabulary
        let ref: DocumentReference = vocabulariesRef.document(vocabulary.id)
        let data = Vocabulary.modelToData(vocabulary: vocabulary)
        
        ref.updateData(data) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }

            if let index: Int = self.vocabularies.firstIndex(matching: vocabulary) {
                if !self.vocabularies[index].isSelected {
                    self.vocabularies[index] = vocabulary
                    complition?(index)
                }
            }
        }
    }
    
    // Update several vocabularies in one response
    func updateVocabularies(_ vocabularies: [Vocabulary], complition: @escaping () -> Void) {
        /// Creating batch for updating in one response
        let batch = db.batch()
        
        /// Creating a loop with references to update simultaniously
        vocabularies.forEach { vocabulary in
            let ref = vocabulariesRef.document(vocabulary.id)
            let data = Vocabulary.modelToData(vocabulary: vocabulary)
            batch.updateData(data, forDocument: ref)
        }
        
        /// Commiting this batch
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
    
    // Update amount of words of currrent vocabulary
    /* It should be called each time when we set (add) or remove word from the vocabulary */
    private func updateAmountOfWords() {
        vocabularyRef.updateData(["words_amount": words.count]) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            self.vocabulary?.wordsAmount = self.words.count
        }
    }
    
    // Update global array of vocabularies with multiple vocabularies
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
    
    // Update global array of words with multiple words
    private func updateLocal(words: [Word]) {
        words.forEach { updatedWord in
            for i in 0..<self.words.count {
                if self.words[i].id == updatedWord.id {
                    self.words[i] = updatedWord
                }
            }
        }
    }
    
    // Update multiple words in one response
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
    
    // Update answer score of a word
    /* It should be called each time when practice has finished */
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
                
                // Update global array of words
                self.updateLocal(words: words)
                complition()
            }
        }
    }
    
    // Update particular word of current vocabulary. Complition is optional
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
                /// Optional complition can have an argument - index of the word in the global array of words
                complition?(index)
            }
        }
    }
    
    // Update word image url in current vocabulary
    func updateWordImageUrl(_ word: Word, complition: @escaping () -> Void) {
        let ref = wordsRef.document(word.id)
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
    
    // Remove vocabulary from db
    func removeVocabulary(_ vocabulary: Vocabulary, complition: @escaping () -> Void) {
        let ref: DocumentReference = vocabulariesRef.document(vocabulary.id)
        
        /// Checking if vocabulary have image folder in store
        self.removeAllWordImagesFrom(vocabulary: vocabulary)
        
        /// Deleting vocabulary with words from database
        ref.delete { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            guard let index = self.vocabularies.firstIndex(matching: vocabulary) else { return }
            self.vocabularies.remove(at: index)
            complition()
        }
    }
    
    // Remove all word images from particular vocabulary
    func removeAllWordImagesFrom(vocabulary: Vocabulary) {
        let ref: DocumentReference = vocabulariesRef.document(vocabulary.id)
        /// Filtering all words with img_url
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
                    // TODO: - try to find a solution with batch
                    self.removeWordImageFrom(vocabularyId: vocabulary.id, wordId: word.id)
                }
            }
        }
    }
    
    // Remove word from current vocabulary
    func removeWord(_ word: Word, complition: @escaping () -> Void) {
        let ref: DocumentReference = wordsRef.document(word.id)
        ref.delete { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let index = self.words.firstIndex(matching: word) else { return }
            self.words.remove(at: index)
            
            /// Updating words amount in current vocabulary
            self.updateAmountOfWords()
            
            /// Checking if word had an image url
            if word.imgUrl.isNotEmpty {
                self.removeWordImageFrom(vocabularyId: self.vocabulary!.id, wordId: word.id) {
                    complition()
                }
            } else {
                complition()
            }
        }
    }
    
    // Remove word image from storage of particular vocabulary
    func removeWordImageFrom(vocabularyId: String? = nil, wordId: String, complition: (() -> Void)? = nil ) {
        guard let vocabulary = self.vocabulary else { return }
        let ref = self.storage.reference()
        /// vocabularyId ?? vocabulary.id - if vocabulary id is nil then will try to find in the current vocabulary
        ref.child("/\(self.user.id)/\(vocabularyId ?? vocabulary.id)/\(wordId).jpg").delete { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            complition?()
        }
    }
}
