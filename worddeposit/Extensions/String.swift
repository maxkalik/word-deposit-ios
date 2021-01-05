//
//  String.swift
//  worddeposit
//
//  Created by Maksim Kalik on 9/24/20.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import UIKit

extension String {
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
}
