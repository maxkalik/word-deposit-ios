//
//  ScrollViewHelper.swift
//  worddeposit
//
//  Created by Maksim Kalik on 4/17/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

final class ScrollViewHelper {
    static var shared = ScrollViewHelper()
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
