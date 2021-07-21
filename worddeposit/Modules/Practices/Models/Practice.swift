//
//  Practice.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/13/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

enum PracticeType {
    case readWordToTranslate
    case readTranslateToWord
}

struct Practice {
    var title: String
    var coverImageSource: String
    var backgroundColor: UIColor
    var type: PracticeType
}
