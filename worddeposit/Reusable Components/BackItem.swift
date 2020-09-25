//
//  SetupBackItem.swift
//  worddeposit
//
//  Created by Maksim Kalik on 9/26/20.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import UIKit

class BackItem {
    static func setupWith(imageName: String?) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 24, height: 24))

        if let imgBackArrow = UIImage(named: imageName ?? "icon_back") {
            let tintedImage = imgBackArrow.withRenderingMode(.alwaysTemplate)
            imageView.image = tintedImage
            imageView.tintColor = Colors.blue
        }
    }
}
