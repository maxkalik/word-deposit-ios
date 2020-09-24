//
//  Array+Idetifiable.swift
//  worddeposit
//
//  Created by Maksim Kalik on 04/09/2020.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import Foundation

extension Array where Element: Identifiable {
    
    func firstIndex(matching: Element) -> Int? {
        for index in 0..<self.count {
            if self[index].id == matching.id {
                return index
            }
        }
        return nil
    }
    
    var only: Element? {
        count == 1 ? first : nil
    }
}


extension Array where Element: Hashable {
    
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
