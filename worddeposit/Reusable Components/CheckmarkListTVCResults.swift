//
//  VocabularyResultsTVC.swift
//  worddeposit
//
//  Created by Maksim Kalik on 03/07/2020.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import UIKit

class CheckmarkListTVCResults: UITableViewController {
    
    // MARK: - Instances
    
    var filteredData = [String]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        filteredData.removeAll()
    }
    
    // MARK: - Methods
    
    func setupTableView() {
        let nib = UINib(nibName: XIBs.VocabularyTVCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: XIBs.VocabularyTVCell)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifiers.CheckedCell, for: indexPath)
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.font = UIFont(name: Fonts.regular, size: 16)
        cell.textLabel?.text = filteredData[indexPath.row]
//        if indexPath.row == selected {
//            cell.accessoryType = .checkmark
//        } else {
//            cell.accessoryType = .none
//        }
        
        return cell
    }
}
