//
//  VocabularyResultsTVC.swift
//  worddeposit
//
//  Created by Maksim Kalik on 03/07/2020.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import UIKit

protocol VocabularyResultsTVCDelegate: VocabularyTVC {
    func resultsWordDidRemove(word: Word)
}

class VocabularyResultsTVC: UITableViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var resultsLabel: UILabel!
    
    // MARK: - Instances
    
    var filteredWords = [Word]()

    weak var delegate: VocabularyResultsTVCDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        filteredWords.removeAll()
    }
    
    // MARK: - Methods
    
    func setupTableView() {
        let nib = UINib(nibName: XIBs.VocabularyTVCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: XIBs.VocabularyTVCell)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: XIBs.VocabularyTVCell, for: indexPath) as? VocabularyTVCell {
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
            
            let word = filteredWords[indexPath.row]
            
            UserService.shared.removeWord(word) { error in
                if error != nil {
                    self.simpleAlert(title: "Error", msg: "Sorry. Cannot remove word. Something wrong.")
                    return
                }
                
                self.filteredWords.remove(at: indexPath.row)
                tableView.deleteRows(at: [IndexPath(item: indexPath.row, section: 0)], with: .fade)
                self.delegate?.resultsWordDidRemove(word: word)
            }
        }
    }
}
