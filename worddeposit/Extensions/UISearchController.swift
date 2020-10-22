//
//  UISearchController.swift
//  worddeposit
//
//  Created by Maksim Kalik on 22/10/2020.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import UIKit

extension UISearchController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.autocapitalizationType = .none
        searchBar.placeholder = "Search"
        searchBar.sizeToFit()
        searchBar.searchBarStyle = .minimal
        definesPresentationContext = true
        
        // custom icons
        let searchIcon = UIImage(named: "icon_search")
        let closeIcon = UIImage(named: "icon_close")
        
        searchBar.setImage(searchIcon, for: .search, state: .normal)
        searchBar.setImage(closeIcon, for: .clear, state: .normal)
        
        searchBar.setPositionAdjustment(UIOffset(horizontal: 8, vertical: .zero), for: .search)
        searchBar.setPositionAdjustment(UIOffset(horizontal: -5, vertical: .zero), for: .clear)
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 4, vertical: .zero)
        
        // Cusom font
        let attributes = [NSAttributedString.Key.font: UIFont(name: Fonts.medium, size: 16), NSAttributedString.Key.foregroundColor: UIColor.black]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = attributes as [NSAttributedString.Key : Any]
        
    }
}
