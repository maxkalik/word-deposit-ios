//
//  SortingForSearch.swift
//  worddeposit
//
//  Created by Maksim Kalik on 01/11/2020.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import Foundation

func sortingForSearch(lsh: String, rsh: String, keyword: String) -> Bool {
    if lsh == keyword && rsh != keyword  {
        return true
    }
    else if lsh.hasPrefix(keyword) && !rsh.hasPrefix(keyword)  {
        return true
    }
    else if lsh.hasPrefix(keyword) && rsh.hasPrefix(keyword) && lsh.count < rsh.count  {
        return true
    }
    else if lsh.contains(keyword) && !rsh.contains(keyword) {
        return true
    }
    else if lsh.contains(keyword) && rsh.contains(keyword) && lsh.count < rsh.count {
        return true
    }
    return false
}
