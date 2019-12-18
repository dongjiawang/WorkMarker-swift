//
//  UIDevice+.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/18.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

extension UIDevice {
    func isiPhoneXMore() -> Bool {
        var isMore = false
        isMore = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0 > CGFloat(0)
        return isMore
    }
}
