//
//  VocabularyResultsTVC.swift
//  worddeposit
//
//  Created by Maksim Kalik on 03/07/2020.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class VocabularyResultsTVC: UITableViewController {

    
    @IBOutlet weak var resultsLabel: UILabel!
    
    var filteredWords = [Word]()
    
    /// Listeners
    var db: Firestore!
    var storage: Storage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        storage = Storage.storage()
        
        setupTableView()
    }
    
    func setupTableView() {
        let nib = UINib(nibName: Identifiers.WordCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Identifiers.WordCell)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("from result tvc", filteredWords)
        return filteredWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.WordCell, for: indexPath) as? WordTableViewCell {
            cell.configureCell(word: filteredWords[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - UITableViewCell Editing

extension VocabularyResultsTVC {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            let selectedWord = filteredWords[indexPath.row]
            
            self.filteredWords.remove(at: indexPath.row)
            tableView.deleteRows(at: [IndexPath(item: indexPath.row, section: 0)], with: .fade)

            // TODO: shoud be rewrited in the singleton

            guard let user = Auth.auth().currentUser else { return }
            
            db.collection("users").document(user.uid).collection("words").document(selectedWord.id).delete { (error) in
                if let error = error {
                    self.simpleAlert(title: "Error", msg: error.localizedDescription)
                    debugPrint(error.localizedDescription)
                    return
                }

                if selectedWord.imgUrl.isNotEmpty {
                    self.storage.reference().child("/\(user.uid)/\(selectedWord.id).jpg").delete { (error) in
                        if let error = error {
                            self.simpleAlert(title: "Error", msg: error.localizedDescription)
                            debugPrint(error.localizedDescription)
                            return
                        }
                    }
                }
                
                
            }
        }
    }
}
