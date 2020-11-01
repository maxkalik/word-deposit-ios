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
    var searchController: UISearchController! {
        didSet {
            searchController.searchBar.autocapitalizationType = .none
            searchController.searchBar.placeholder = "Search"
            searchController.searchBar.sizeToFit()
            searchController.searchBar.searchBarStyle = .minimal
            definesPresentationContext = true
            
            // custom icons
            let searchIcon = UIImage(named: Icons.Search)
            let closeIcon = UIImage(named: Icons.Close)
            
            searchController.searchBar.setImage(searchIcon, for: .search, state: .normal)
            searchController.searchBar.setImage(closeIcon, for: .clear, state: .normal)
            
            searchController.searchBar.setPositionAdjustment(UIOffset(horizontal: 8, vertical: .zero), for: .search)
            searchController.searchBar.setPositionAdjustment(UIOffset(horizontal: -5, vertical: .zero), for: .clear)
            searchController.searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 4, vertical: .zero)
            
            // Cusom font
            let attributes = [NSAttributedString.Key.font: UIFont(name: Fonts.medium, size: 16), NSAttributedString.Key.foregroundColor: UIColor.black]
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = attributes as [NSAttributedString.Key : Any]
        }
    }
    
    /// Restoration state for UISearchController
    var restoredState = SearchControllerRestorableState()
    
    // MARK: - Lifecycle methods
    
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
