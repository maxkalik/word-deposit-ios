//
//  SearchableTVC.swift
//  worddeposit
//
//  Created by Maksim Kalik on 22/10/2020.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import UIKit

class SearchableTVC: UITableViewController {

    /// Search controller to help us with filtering items in the table view
    var searchController: UISearchController!
    
    /// Restoration state for UISearchController
    var restoredState = SearchControllerRestorableState()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Restore the searchController's active state.
        if restoredState.wasActive {
            searchController.isActive = restoredState.wasActive
            restoredState.wasActive = false
            
            if restoredState.wasFirstResponder {
                searchController.searchBar.becomeFirstResponder()
                restoredState.wasFirstResponder = false
            }
        }
    }
}
