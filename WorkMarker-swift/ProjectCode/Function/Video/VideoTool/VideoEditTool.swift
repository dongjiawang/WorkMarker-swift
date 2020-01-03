//
//  VideoEditTool.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2020/1/3.
//  Copyright © 2020 dongjiawang. All rights reserved.
//

import UIKit
import Photos

class VideoEditTool: NSObject {

    typealias exportResult = (_ url: URL) -> Void
    var saveResultBlock: exportResult?
    
    func getVideoSavePath() -> String {
        let path = NSTemporaryDirectory()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let nowTimeString = formatter.string(from: Date.init(timeIntervalSinceNow: 0))
        let fileName = path + "/\(nowTimeString).mp4"
        return fileName
    }
    
    func getVideoMergeFilePath() -> String {
        let path = NSTemporaryDirectory()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let nowTimeString = formatter.string(from: Date.init(timeIntervalSinceNow: 0))
        let fileName = path + "/\(nowTimeString).mp4"
        return fileName
    }
    
    func getVideoOriginalVideoAsset(videoAsset: AVAsset, videoTrack: AVMutableCompositionTrack, composition: AVMutableComposition) -> AVMutableCompositionTrack {
        let originalAudioAssetTrack = videoAsset.tracks(withMediaType: .audio).first
        let originalAudioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        try! originalAudioCompositionTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: videoTrack.timeRange.duration), of: originalAudioAssetTrack!, at: CMTime.zero)
        
        return originalAudioCompositionTrack!
    }
    
    func exportVideo(exportSession: AVAssetExportSession, exportResult: exportResult?) {
        exportSession.outputFileType = .mp4
        exportSession.outputURL = URL(fileURLWithPath: getVideoMergeFilePath())
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .failed:
                WMHUD.textHUD(text: "导出视频失败:\(String(describing: exportSession.error?.localizedDescription))", delay: 1)
            case .completed:
                DispatchQueue.main.async {
                    self.saveVideoToLibrary(videoURL: exportSession.outputURL!, result: exportResult)
                }
            default:
                break
            }
        }
    }
        
    func saveVideoToLibrary(videoURL: URL, result: exportResult?) {
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoURL.path) {
            PHPhotoLibrary.shared().performChanges({
                    _ = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                    if result != nil {
                        result!(videoURL)
                    }
            }) { (finish, error) in
                if error != nil {
                    WMHUD.textHUD(text: "视频保存相册失败，请设置软件读取相册权限", delay: 1)
                }
            }
        }
    }
}
