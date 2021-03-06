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
    
    var filteredData = [String]() {
        didSet {
            if !filteredData.isEmpty {
                guard let selectedStr = selected else { return }
                selectedIndex = filteredData.firstIndex(of: selectedStr)
            }
        }
    }
    private var selectedIndex: Int?
    var selected: String?
    
    // MARK: - Lifecycle
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        filteredData.removeAll()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        if let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifiers.CheckedCell, for: indexPath) as? CheckmarkListTVCell {
            cell.configure(title: filteredData[indexPath.row], isMarked: indexPath.row == selectedIndex)
            return cell
        }

        return UITableViewCell()
    }
}
