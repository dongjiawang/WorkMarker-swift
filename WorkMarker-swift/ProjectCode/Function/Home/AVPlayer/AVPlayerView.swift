//
//  AVPlayerView.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/12.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices


/// 播放进度，播放状态 回调
protocol AVPlayerViewDelegate: NSObjectProtocol {
    
    /// 播放进度回调
    /// - Parameters:
    ///   - current: 当前播放时间
    ///   - total: 总时长
    func onProgressUpdate(current: CGFloat, total: CGFloat)
    
    /// 播放状态回调
    /// - Parameter status: 播放器状态
    func onPlayItemStatusUpdate(status: AVPlayerItem.Status)
}

class AVPlayerView: UIView {
    
    /// 代理
    var delegate: AVPlayerViewDelegate?
    /// 视频播放地址
    var sourceURL: URL?
    /// 视频路径scheme
    var sourceScheme: String?
    /// 视频资源
    var urlAsset: AVURLAsset?
    /// playerItem
    var playerItem: AVPlayerItem?
    /// 播放器
    var player: AVPlayer?
    /// 播放器图层
    var playerLayer: AVPlayerLayer = AVPlayerLayer()
    /// 播放器观察者
    var timeObserver: Any?
    
    /// 缓冲数据
    var data: Data?
    
    /// 视频下载的ssession
    var session: URLSession?
    /// 视频下载 task
    var task: URLSessionTask?
    
    /// 视频下载请求响应
    var response: HTTPURLResponse?
    /// AVAssetResourceLoadingRequest 的数组
    var pendingCacheOperation = [AVAssetResourceLoadingRequest]()
    
    /// 缓存的 key 值
    var cacheFilekey: String?
    /// 查找本地缓存的 operation
    var queryCacheOperation: Operation?
    
    /// 取消所有队列
    var cancelLoadingQueue: DispatchQueue?
    
    init() {
        super.init(frame: .zero)
        initSubview()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubview()
    }
    
    func initSubview() {
        session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
            
        playerLayer = AVPlayerLayer(player: player)
        self.layer.addSublayer(self.playerLayer)
        
        addProgressObserver()
        
        cancelLoadingQueue = DispatchQueue(label: "com.start.cancelLoadingqueue")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer.frame = self.layer.bounds
        CATransaction.commit()
    }
    
    func setPlayerVideoGravity(videoGravity: AVLayerVideoGravity) {
        playerLayer.videoGravity = videoGravity;
    }
    
    func setPlayerSourceUrl(url: String?) {
        // 过滤中文和特殊字符
        let sourceurl = url?.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "`#%^{}\"[]|\\<> "))
        sourceURL = URL(string: sourceurl ?? "")
        
        let components = URLComponents(url: sourceURL!, resolvingAgainstBaseURL: false)
        sourceScheme = components?.scheme
        cacheFilekey = sourceURL?.absoluteString
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 重新开始播放
    func replay() {
        
    }
}

// MARK: - 观察者
extension AVPlayerView {
    
    /// 监听播放器的状态
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if playerItem?.status == .readyToPlay {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                playerLayer.isHidden = false
                CATransaction.commit()
            }
            delegate?.onPlayItemStatusUpdate(status: playerItem?.status ?? AVPlayerItem.Status.unknown)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    /// 监听播放进度
    func addProgressObserver() {
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: .main, using: { (time) in
            let current = CMTimeGetSeconds(time)
            let total = CMTimeGetSeconds(self.playerItem?.duration ?? CMTime.init())
            if total == current {
                // 重新播放
                self.replay()
            }
            self.delegate?.onProgressUpdate(current: CGFloat(current), total: CGFloat(total))
        })
    }
    
    /// 移除观察者
    func removeObserver() {
        playerItem?.removeObserver(self, forKeyPath: "status")
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
    }
}

// MARK: - sesstion 代理回调  视频下载缓存

extension AVPlayerView: URLSessionDelegate, URLSessionDataDelegate {
    
    /// 资源请求获取响应
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
    }
}

// MARK: - AVAssetResourceLoaderDelegate

extension AVPlayerView: AVAssetResourceLoaderDelegate {
    
}
