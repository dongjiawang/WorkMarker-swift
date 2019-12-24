//
//  WMHUD.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/24.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit
import PKHUD

class WMHUD: NSObject {
    
    class func textHUD(text: String?, delay: TimeInterval) {
        HUD.flash(.label(text), delay: delay)
    }
    
    class func errorHUD(text: String?, subText: String?, delay: TimeInterval) {
        HUD.flash(.labeledError(title: text, subtitle: subText), delay: delay)
    }
    
    class func progressHUD(text: String?, subText: String?) {
        HUD.show(.labeledProgress(title: text, subtitle: subText))
    }
    
    class func activityHUD() {
        HUD.show(.systemActivity)
    }
    
    class func hideHUD() {
        HUD.hide()
    }
}
