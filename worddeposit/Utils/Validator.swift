//
//  Validator.swift
//  worddeposit
//
//  Created by Maksim Kalik on 9/24/20.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import UIKit

class Validator {
    func validate(text: String, with rules: [Rule]) -> String? {
        return rules.compactMap({ $0.check(text) }).first
    }
}

struct Rule {
    let check: (String) -> String?
    
    static let notEmpty = Rule(check: {
        return $0.isEmpty ? "Must not be empty" : nil
    })
    
    static let email = Rule(check: {
        let regex = #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: $0) ? nil : "Must have valid email"
    })
    
    static let password = Rule(check: {
        return $0.count >= 6 ? nil : "Password must have at least 6 characters"
    })
}
