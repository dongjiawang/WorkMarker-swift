//
//  AVPlayerManager.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/13.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit
import AVKit

class AVPlayerManager: NSObject {
    var playerArray = [AVPlayer]()
    
    private static let instance = {() -> AVPlayerManager in
        return AVPlayerManager.init()
    }()
    
    private override init() {
        super.init()
    }
    
    class func shared() -> AVPlayerManager {
        return instance
    }
    
    static func setAudioMode() {
        do {
            try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("设置音频模式错误:" + error.localizedDescription)
        }
    }
    
    func play(player: AVPlayer) {
        for object in playerArray {
            object.pause()
        }
        if !playerArray.contains(player) {
            playerArray.append(player)
        }
        player.play()
    }
    
    func pause(player: AVPlayer) {
        if playerArray.contains(player) {
            player.pause()
        }
    }
    
    func pauseAll(player: AVPlayer) {
        for object in playerArray {
            object.pause()
        }
    }
    
    func replay(player: AVPlayer) {
        for object in playerArray {
            object.pause()
        }
        if playerArray.contains(player) {
            player.seek(to: .zero)
            play(player: player)
        } else {
            play(player: player)
        }
    }
}
