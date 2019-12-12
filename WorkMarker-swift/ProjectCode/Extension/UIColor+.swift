//
//  UIColor+.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/12.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    func drawToImage(size: CGSize) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        var image: UIImage? = nil
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        guard let content = UIGraphicsGetCurrentContext() else {
            return image
        }
        content.setFillColor(self.cgColor)
        content.fill(rect)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
