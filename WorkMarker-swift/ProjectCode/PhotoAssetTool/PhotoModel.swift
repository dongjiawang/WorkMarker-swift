//
//  PhotoModel.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/25.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit
import Photos

class PhotoModel: NSObject {
    var photoAsset: PHAsset?
    var videoAsset: AVAsset?
    var videoUrlAsset: AVURLAsset?
    var isSelected = false
    var unAble = false
    var localIdentifiter: String?
    var videoDuration: String?
    var thumbnailImage: UIImage?
    var originalImage: UIImage?
    
    func setPhotoAsset(asset: PHAsset) {
        self.photoAsset = asset
        if asset.mediaType == .video {
            self.videoDuration = self.calculateVideoTime(duration: asset.duration)
        }
    }
    
    func calculateVideoTime(duration: TimeInterval) -> String {
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
    
}
