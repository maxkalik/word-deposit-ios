import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

final class UserService {
    
    static let shared = UserService() // global constant
    
    // Variables
    private(set) var user: User?
    private(set) var vocabularies = [Vocabulary]()
    private(set) var words = [Word]() // did set should triger updating words amount
    private(set) var vocabulary: Vocabulary?
    
    // References
    private var userRef: DocumentReference!
    private var vocabulariesRef: CollectionReference! // vocabularies collection
    private var vocabularyRef: DocumentReference! // with vocabulary id
    private var wordsRef: CollectionReference!
    
    // Listeners
    var auth: Auth = Auth.auth()
    var db: Firestore = Firestore.firestore()
    private var storage: Storage = Storage.storage()
    
    private init() {} // original singleton pattern difinition
    
    // MARK: - Methods - AUTH
    
    // Sign in
    func signIn(withEmail email: String, password: String, complition: @escaping (Error?) -> Void) {
        auth.signIn(withEmail: email, password: password) { _, error in
            complition(error)
        }
    }
    
    // Sign up
    func signUp(withEmail email: String, password: String, complition: @escaping (Error?) -> Void) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                debugPrint(error.localizedDescription)
                complition(error)
                return
            }
            guard let firUser = result?.user else { return }
            let user = User.init(id: firUser.uid, email: email)
            
            self.setUser(user) { error in
                if let error = error {
                    complition(error)
                    debugPrint(error.localizedDescription)
                    return
                }
                complition(nil)
            }
        }
    }
    
    // Reset password
    func resetPassword(withEmail email: String, complition: @escaping (Error?) -> Void) {
        auth.sendPasswordReset(withEmail: email) { error in
            complition(error)
        }
    }
    
    // Delete account
    func deleteAccount(complition: @escaping (Error?) -> Void) {
        guard let currentUser = auth.currentUser else { return }
        currentUser.delete { error in
            complition(error)
        }
    }
    
    // Logout
    func logout(complition: @escaping (Error?) -> Void) {
        signOut { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                complition(error)
                return
            } else {
                self.user = nil
                self.words.removeAll()
                self.vocabularies.removeAll()
                self.vocabulary = nil
                complition(nil)
            }
        }
    }
    
    private func signOut(complition: @escaping (Error?) -> Void) {
        do {
            try auth.signOut()
            complition(nil)
        } catch let error as NSError {
            complition(error)
            debugPrint(error.localizedDescription)
            return
        }
    }
    
    // MARK: - Methods - GET
    
    // Get current user from database
    func fetchCurrentUser(complition: @escaping (Error?, User?) -> Void) {
        guard let currentUser = auth.currentUser else { return }
        userRef = self.db.collection("users").document(currentUser.uid)
        userRef.getDocument { (document, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                complition(error, nil)
                return
            }
            
            if let document = document, document.exists {
                guard let data = document.data() else { return }
                self.user = User.init(data: data)
                complition(nil, self.user)
            } else {
                self.signOut { error in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                        return
                    }
                    complition(nil, nil)
                }
            }
        }
    }
    
    // Fetch vocabularies
    func fetchVocabularies(complition: @escaping (Error?, [Vocabulary]?) -> Void) {
        // what if userid is empty?
        vocabulariesRef = userRef.collection("vocabularies")
        vocabulariesRef.order(by: "timestamp", descending: true).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting vocabularies: \(error)")
                complition(error, nil)
                return
            } else {
                self.vocabularies.removeAll()
                guard let documents = snapshot?.documents else { return }
                for document in documents {
                    let data = document.data()
                    let vocabulary = Vocabulary.init(data: data)
                    self.vocabularies.append(vocabulary)
                }
                complition(nil, self.vocabularies)
            }
        }
    }
    
    // Get amount of words from particular vocabulary
    func getAmountOfWordsFrom(vocabulary: Vocabulary, complition: @escaping (Int?) -> Void) {
        let ref = vocabulariesRef.document(vocabulary.id)
        let wordsRef = ref.collection("words")
        wordsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                guard let snap = snapshot else { return }
                if vocabulary.wordsAmount != snap.count {
                    /// Update vocabulary words amount
                    self.updateAmountOfWords(for: vocabulary, amount: snap.count, in: ref) { amount in
                        complition(amount)
                    }
                } else {
                    complition(snap.count)
                }
            }
        }
    }
    
    // Get current vocabulary and set it to the var
    func getCurrentVocabulary() {
        /// here should be checking if array is not empty then check if any vocabulary is Selected if not turn on and update
        let index = self.vocabularies.firstIndex { vocabulary -> Bool in
            return vocabulary.isSelected
        }
        guard let i = index else { return }
        self.vocabulary = self.vocabularies[i]
        
        /// Creating references
        self.vocabularyRef = self.vocabulariesRef.document(self.vocabularies[i].id)
        self.wordsRef = vocabularyRef.collection("words")
    }
    
    // Fetch all words from particular vocabulary (id) and complition will take an array of fetched words
    func fetchWords(complition: @escaping (Error?, [Word]?) -> Void) {
        /// Setup global ref if vocabularyRef has a currenct vocabulary id
        let ref = wordsRef.order(by: "timestamp", descending: true)
        if self.vocabulary != nil {
            ref.getDocuments { (snapshot, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    complition(error, nil)
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
                complition(nil, self.words)
            }
        }
    }
    
    // MARK: - Methods - SET
    
    // Set up new User to the database
    func setUser(_ user: User, complition: @escaping (Error?) -> Void) {
        let ref = db.collection("users").document(user.id)
        let data = User.modelToData(user: user)
        
        ref.setData(data) { error in
            complition(error)
        }
    }
    
    // Create new vocabulary and set to the the db user.vocabularies/<vocabulary>
    func setVocabulary(_ vocabulary: Vocabulary, complition: @escaping (Error?, String?) -> Void) {
        /// creating new id
        var vocabulary = vocabulary
        let ref = vocabulariesRef.document()
        vocabulary.id = ref.documentID
        
        let data = Vocabulary.modelToData(vocabulary: vocabulary)
        ref.setData(data) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                complition(error, nil)
                return
            }
            self.vocabularies.insert(vocabulary, at: 0)
            complition(nil, vocabulary.id)
        }
    }
    
    // Create new word and set to the db user.vocabularies/vocabulary.words/<word>
    func setWord(
        imageData: Data? = nil,
        example: String,
        translation: String,
        description: String? = nil,
        complition: @escaping (Error?, Word?) -> Void
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
            setWordImage(data: imageData, id: word.id) { error, url in
                /// Adding img url string to the word instance
                guard let url = url else { return }
                word.imgUrl = url.absoluteString
                /// Setting word data to the db
                self.setWordData(word, to: ref) { error in
                    complition(error, word)
                }
            }
        } else {
            /// Setting word data to the db
            setWordData(word, to: ref) { error in
                complition(error, word)
            }
        }
    }
    
    // Set word data to the db. Works only with ref
    private func setWordData(_ word: Word, to ref: DocumentReference, complition: @escaping (Error?) -> Void) {
        let data = Word.modelToData(word: word)
        ref.setData(data) { error in
            if let error = error {
                complition(error)
                debugPrint(error.localizedDescription)
                return
            }
            self.words.insert(word, at: 0)
            self.updateAmountOfWordsInSelectedVocabulary()
            complition(nil)
        }
    }
    
    // Set word image data to the storage user_id/vocabulary_id/word_id.jpg
    func setWordImage(data: Data?, id: String, complition: @escaping (Error?, URL?) -> Void) {
        guard let user = self.user, let vocabulary = self.vocabulary, let data = data else { return }
        let ref: StorageReference = Storage.storage().reference().child("/\(user.id)/\(vocabulary.id)/\(id).jpg")
        let metadata: StorageMetadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        ref.putData(data, metadata: metadata) { (storageMetadata, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                complition(error, nil)
                return
            }
            
            ref.downloadURL { (url, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    complition(error, nil)
                    return
                }
                guard let url = url else { return }
                /// Complition with url argument for setting it to the word data when complite this uploading process
                complition(nil, url)
            }
        }
    }
    
    // MARK: - Methods - UPDATE
    
    // Update user profile
    func updateUser(_ user: User, complition: ((Error?) -> Void)? = nil) {
        let data = User.modelToData(user: user)
        userRef.updateData(data) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                complition?(error)
                return
            }
            self.user = user
            complition?(nil)
        }
    }
    
    // Switch selected vocabulary - updating is_selected property in 2 vocabularies
    func switchSelectedVocabulary(from: Vocabulary, to: Vocabulary, complition: @escaping (Error?) -> Void) {
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
                complition(error)
                return
            } else {
                /// Updating local array of vocabularies
                self.updateLocal(vocabularies: [from, to])
                complition(nil)
            }
        }
    }
    
    // Update whole vocabulry
    func updateVocabulary(_ vocabulary: Vocabulary, complition: ((Error?, Int?) -> Void)? = nil) {
        
        // TODO: - could vocabulariesRef be nil?
        // TODO: - what if we can pass an array with what we want update particularly?
        
        /// Taking a ref with a particular vocabulary
        let ref: DocumentReference = vocabulariesRef.document(vocabulary.id)
        let data = Vocabulary.modelToData(vocabulary: vocabulary)
        
        ref.updateData(data) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                complition?(error, nil)
                return
            }

            if let index: Int = self.vocabularies.firstIndex(matching: vocabulary) {
                self.vocabularies[index] = vocabulary
                complition?(nil, index)
                if vocabulary.isSelected {
                    self.vocabulary = vocabulary
                }
            }
        }
    }
    
    // Update several vocabularies in one response
    func updateVocabularies(_ vocabularies: [Vocabulary], complition: @escaping (Error?) -> Void) {
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
                complition(error)
                return
            } else {
                self.updateLocal(vocabularies: vocabularies)
                complition(nil)
            }
        }
    }
    
    // Update amount of words in any vocabulary
    private func updateAmountOfWords(for vocabulary: Vocabulary, amount: Int, in ref: DocumentReference, complition: @escaping (Int?) -> Void) {
        ref.updateData(["words_amount": amount]) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            if let index: Int = self.vocabularies.firstIndex(matching: vocabulary) {
                self.vocabularies[index].wordsAmount = amount
                complition(amount)
            }
        }
    }
    
    // Update amount of words of currrent vocabulary
    /* It should be called each time when we set (add) or remove word from the vocabulary */
    private func updateAmountOfWordsInSelectedVocabulary() {
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
    func updateWords(_ words: [Word], complition: @escaping (Error?) -> Void) {
        let batch = db.batch()
        words.forEach { word in
            let ref = wordsRef.document(word.id)
            let data = Word.modelToData(word: word)
            batch.updateData(data, forDocument: ref)
        }
        batch.commit() { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                complition(error)
                return
            } else {
                self.updateLocal(words: words)
                complition(nil)
            }
        }
    }
    
    // Update answer score of a word
    /* It should be called each time when practice has finished */
    func updateAnswersScore(_ words: [Word], complition: @escaping (Error?) -> Void) {
        let batch = db.batch()
        words.forEach { word in
            let ref = wordsRef.document(word.id)
            batch.updateData(["right_answers" : word.rightAnswers, "wrong_answers" : word.wrongAnswers], forDocument: ref)
        }
        batch.commit() { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                complition(error)
                return
            } else {
                
                // Update global array of words
                self.updateLocal(words: words)
                complition(nil)
            }
        }
    }
    
    // Update particular word of current vocabulary. Complition is optional
    func updateWord(_ word: Word, complition: ((Error?, Int?) -> Void)? = nil) {
        let ref = wordsRef.document(word.id)
        let data = Word.modelToData(word: word)
        ref.updateData(data) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                complition?(error, nil)
                return
            }
            
            if let index: Int = self.words.firstIndex(matching: word) {
                self.words[index] = word
                /// Optional complition can have an argument - index of the word in the global array of words
                complition?(nil, index)
            }
        }
    }
    
    // Update word image url in current vocabulary
    func updateWordImageUrl(_ word: Word, complition: @escaping (Error?) -> Void) {
        let ref = wordsRef.document(word.id)
        ref.updateData(["img_url" : word.imgUrl]) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                complition(error)
                return
            }
            if let index: Int = self.words.firstIndex(matching: word) {
                self.words[index].imgUrl = word.imgUrl
                complition(nil)
            }
        }
    }
    
    // MARK: - Methods - REMOVE
    
    // Remove current user with all vocabularies and words with images
    func removeAccountData(complition: @escaping (Error?) -> Void) {
        let group = DispatchGroup()
        vocabularies.forEach { vocabulary in
            group.enter()
            self.removeAllWordImagesFrom(vocabulary: vocabulary) {
                group.leave()
            }
        }
        group.notify(queue: .main) {
            self.userRef.delete { error in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    complition(error)
                    return
                }
                complition(nil)
            }
        }
    }
    
    // Remove vocabulary from db
    func removeVocabulary(_ vocabulary: Vocabulary, complition: @escaping (Error?) -> Void) {
        let ref: DocumentReference = vocabulariesRef.document(vocabulary.id)
        
        /// Checking if vocabulary have image folder in store
        self.removeAllWordImagesFrom(vocabulary: vocabulary)
        
        /// Deleting vocabulary with words from database
        ref.delete { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                complition(error)
                return
            }
            guard let index = self.vocabularies.firstIndex(matching: vocabulary) else { return }
            print("00 - VOCABULARY BUG INVISTIGATION. Vocabulary index in UserService: \(index)")
            self.vocabularies.remove(at: index)
            complition(nil)
        }
    }
    
    // Remove all word images from particular vocabulary
    func removeAllWordImagesFrom(vocabulary: Vocabulary, complition: (() -> Void)? = nil) {
        let group = DispatchGroup()
        let ref: DocumentReference = vocabulariesRef.document(vocabulary.id)
        /// Filtering all words with img_url
        ref.collection("words").order(by: "img_url").getDocuments { (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            guard let documents = snapshot?.documents else { return }
            for document in documents {
                group.enter()
                let data = document.data()
                let word = Word.init(data: data)
                if word.imgUrl.isNotEmpty {
                    // TODO: - try to find a solution with batch
                    self.removeWordImageFrom(vocabularyId: vocabulary.id, wordId: word.id) {
                        group.leave()
                    }
                }
            }
        }
        group.notify(queue: .main) {
            complition?()
        }
    }
    
    // Remove word from current vocabulary
    func removeWord(_ word: Word, complition: @escaping (Error?) -> Void) {
        let ref: DocumentReference = wordsRef.document(word.id)
        ref.delete { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                complition(error)
                return
            }
            
            guard let index = self.words.firstIndex(matching: word) else { return }
            self.words.remove(at: index)
            
            /// Updating words amount in current vocabulary
            self.updateAmountOfWordsInSelectedVocabulary()
            
            /// Checking if word had an image url
            if word.imgUrl.isNotEmpty {
                self.removeWordImageFrom(vocabularyId: self.vocabulary!.id, wordId: word.id) {
                    complition(nil)
                }
            } else {
                complition(nil)
            }
        }
    }
    
    // Remove word image from storage of particular vocabulary
    func removeWordImageFrom(vocabularyId: String? = nil, wordId: String, complition: (() -> Void)? = nil ) {
        guard let user = self.user, let vocabulary = self.vocabulary else { return }
        let ref = self.storage.reference()
        /// vocabularyId ?? vocabulary.id - if vocabulary id is nil then will try to find in the current vocabulary
        ref.child("/\(user.id)/\(vocabularyId ?? vocabulary.id)/\(wordId).jpg").delete { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            complition?()
        }
    }
}
