//
//  BubbleLabel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 1/3/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

class BubbleLabel: PracticeDeskItemLabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonSetup()
    }
    
    
    func onPress() {
        UIView.animate(withDuration: 0.3) { [self] in
            alpha = 1
        }
    }
    
    func onFinishPress() {
        UIView.animate(withDuration: 0.3) { [self] in
            alpha = 0
        }
    }
    
    func commonSetup() {
        alpha = 0
        backgroundColor = Colors.dark.withAlphaComponent(0.9)
        layer.cornerRadius = Radiuses.large
        layer.masksToBounds = true
        lineBreakMode = .byTruncatingTail
        numberOfLines = 0
        font = UIFont(name: Fonts.bold, size: 16)
        textAlignment = .center
        textColor = .white
    }
}
