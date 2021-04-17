//
//  PracticeReadHelper.swift
//  worddeposit
//
//  Created by Maksim Kalik on 4/17/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

final class PracticeReadHelper {
    static var shared = PracticeReadHelper()
    private init() {}
    
    func transofrmOnScroll(wordImage: inout RoundedImageView, with offset: CGPoint) {
        if offset.y < 0.0 {
            wordImage.layer.transform = CATransform3DIdentity
        } else {
            let scaleFactor = 1 + (-1 * offset.y / (wordImage.frame.size.height / 2))
            var transform = CATransform3DTranslate(CATransform3DIdentity, 0, (offset.y), 0)
        
            if scaleFactor >= 0.5 {
                transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1)
                wordImage.layer.transform = transform
                wordImage.layer.cornerRadius = (Radiuses.large + offset.y / 2)
            }
        }
    }
}
