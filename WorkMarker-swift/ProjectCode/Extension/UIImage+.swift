//
//  UIImage+.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/12.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func fixOrientation() -> UIImage? {
        guard self.imageOrientation == .up else {
            return self
        }
        let transForm = CGAffineTransform.identity
        switch self.imageOrientation {
        case .down, .downMirrored:
            transForm.translatedBy(x: self.size.width, y: self.size.height)
            transForm.rotated(by: CGFloat(Double.pi))
        case .left, .leftMirrored:
            transForm.translatedBy(x: self.size.width, y: 0)
            transForm.rotated(by: CGFloat(Double.pi / 2))
        case .right, .rightMirrored:
            transForm.translatedBy(x: 0, y: self.size.height)
            transForm.rotated(by: CGFloat(-Double.pi / 2))
        default:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transForm.translatedBy(x: self.size.width, y: 0)
            transForm.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transForm.translatedBy(x: self.size.height, y: 0)
            transForm.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        let content = CGContext.init(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 0, bytesPerRow: 0, space: (self.cgImage?.colorSpace!)!, bitmapInfo: (self.cgImage?.bitmapInfo)!.rawValue)
             
        content?.concatenate(transForm)
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            content?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
        default:
            content?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        let cgImage = content?.makeImage()!
        content?.flush()
        
        return UIImage(cgImage: cgImage!)
    }
}
