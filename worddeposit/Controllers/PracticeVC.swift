import UIKit
import Firebase
import FirebaseFirestore

class PracticeVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var welcomeLbl: UILabel!
    @IBOutlet weak var wordsLbl: UILabel!
    
    // MARK: - Instances
    var user = User()
    var words = [Word]()
    var auth: Auth!
    var db: Firestore!
    var handle: AuthStateDidChangeListenerHandle?

    // MARK: - Lifecyles
    
    override func viewDidLoad() {
        auth = Auth.auth()
        db = Firestore.firestore()
        welcomeLbl.isHidden = true
        wordsLbl.isHidden = true
        activityIndicator.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCurrentUser()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        auth.removeStateDidChangeListener(handle!)
    }
    
    // MARK: - Methods
    
    private func getCurrentUser() {
        handle = auth.addStateDidChangeListener { (auth, user) in
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
                    self.welcomeLbl.text = self.user.email
                    self.welcomeLbl.isHidden = false
                    self.fetchWords(from: userRef)
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    private func fetchWords(from: DocumentReference) {
        let wordsRef = from.collection("words")
        
        wordsRef.getDocuments { (snapshot, error) in
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
            self.activityIndicator.stopAnimating()
            self.wordsLbl.text = String(self.words.count)
            self.wordsLbl.isHidden = false
        }
    }
}
