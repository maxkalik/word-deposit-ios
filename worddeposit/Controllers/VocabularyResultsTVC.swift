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
        print("Results", filteredWords)
        
        db = Firestore.firestore()
        storage = Storage.storage()
        
        setupTableView()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func setupTableView() {
        let nib = UINib(nibName: Identifiers.WordCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Identifiers.WordCell)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.WordCell, for: indexPath) as? WordTableViewCell {
            cell.configureCell(word: filteredWords[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}
