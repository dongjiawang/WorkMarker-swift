//
//  UIDevice+.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/18.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit
import WebKit
import Kingfisher

extension UIDevice {
    func isiPhoneXMore() -> Bool {
        var isMore = false
        isMore = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0 > CGFloat(0)
        return isMore
    }
    
    func clearCookie() {
        URLCache.shared.removeAllCachedResponses()
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date.init(timeIntervalSince1970: 0)) {
            
        }
    }
    
    func clearImageCache() {
        ImageCache.default.clearDiskCache()
        ImageCache.default.clearMemoryCache()
    }
    
    func getAudioCachePath() -> String {
        let documentPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        return (documentPath?.appending("AudioCache"))!
    }
    
    func clearTmpDirectory() {
        let tmpDirectoryArray = try! FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
        for file in tmpDirectoryArray {
            let removePath = "\(NSTemporaryDirectory())\(file)"
            try! FileManager.default.removeItem(atPath: removePath)
        }
    }
    
    func folderSizeAtPath(folderPath: String) -> Double {
        var folderSize: Double = 0
        let manager = FileManager.default
        if manager.fileExists(atPath: folderPath) == false {return 0}
        guard let childFilesEnumerator = manager.subpaths(atPath: folderPath)?.enumerated() else { return 0 }
                
        for fileName in childFilesEnumerator {
            let fileAbsolutePath = folderPath.appending("/\(fileName)")
            folderSize += UIDevice.current.fileSizeAtPath(filePath: fileAbsolutePath)
        }
        
        return folderSize
    }
    
    func fileSizeAtPath(filePath: String) -> Double {
        let manager = FileManager.default
        if manager.fileExists(atPath: filePath) {
            return try! manager.attributesOfItem(atPath: filePath)[FileAttributeKey.size] as! Double
        }
        return 0
    }
    
}
