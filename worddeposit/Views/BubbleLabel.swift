//
//  BubbleLabel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 1/3/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

struct BubbleLabelParams {
    var collectionViewFrame: CGRect
    var cellFrame: CGRect
    var viewContentOffcetY: CGFloat
    var text: String
}

class BubbleLabel: PracticeDeskItemLabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonSetup()
    }
    
    private func prepareForLongPress(with bubbleLabelParams: BubbleLabelParams) {
        text = bubbleLabelParams.text
        frame = CGRect(x: 0, y: 0, width: bubbleLabelParams.collectionViewFrame.size.width, height: 42)
        let font = UIFont(name: Fonts.bold, size: 16)
        let colViewY = bubbleLabelParams.collectionViewFrame.origin.y
        let offcetY = bubbleLabelParams.viewContentOffcetY
        let cellY = bubbleLabelParams.cellFrame.origin.y
        let cellHeight = bubbleLabelParams.cellFrame.height / 2
        let constrainedWidth = frame.size.width - padding.left - padding.right
        if let superview = superview {
            center = superview.center
            frame.origin.y = colViewY - offcetY + cellY - cellHeight
            frame.size.height += bubbleLabelParams.text.height(withConstrainedWidth: constrainedWidth, font: font!)
        }
    }
    
    func onPress(with bubbleLabelParams: BubbleLabelParams) {
        prepareForLongPress(with: bubbleLabelParams)
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
