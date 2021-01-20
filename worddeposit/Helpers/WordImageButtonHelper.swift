//
//  WordImageButtonHelper.swift
//  worddeposit
//
//  Created by Maksim Kalik on 1/20/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

final class WordImageButtonHelper {
    static var shared = WordImageButtonHelper()
    private init() {}
    
    func transformOnScroll(with offset: CGPoint, and objectHeight: CGFloat) -> CATransform3D {
        if offset.y < 0.0 {
            var transform = CATransform3DTranslate(CATransform3DIdentity, 0, (offset.y), 0)
            let scaleFactor = 1 + (-1 * offset.y / (objectHeight / 2))
            transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1)
            return transform
        } else {
            return CATransform3DIdentity
        }
    }
}
