//
//  ProfileTVCCheckmark.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/17/20.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import UIKit

class ProfileTVCCheckmark: UITableViewController {

    var data: [String]!
    var selected: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let data = data, let selected = selected else { return }
        
        print(data)
        print(selected)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifiers.CheckedCell, for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        if indexPath.row == selected {
            cell.accessoryType = .checkmark
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selected != nil {
            tableView.cellForRow(at: IndexPath(row: selected, section: 0))?.accessoryType = .none
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            selected = indexPath.row
            tableView.deselectRow(at: indexPath, animated: true)
        }
        // + delegate
    }
    
}
