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
    var pendingRequests = [AVAssetResourceLoadingRequest]()
    
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
    
    /// 数据源
    /// - Parameter url: 视频地址
    func setPlayerSourceUrl(url: String?) {
        // 过滤中文和特殊字符
        let sourceurl = url?.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "`#%^{}\"[]|\\<> ").inverted)
        sourceURL = URL(string: sourceurl ?? "")
        
        let components = URLComponents(url: sourceURL!, resolvingAgainstBaseURL: false)
        sourceScheme = components?.scheme
        cacheFilekey = sourceURL?.absoluteString
        // 开启缓存线程
        queryCacheOperation = WebCacheManager.shared().queryURLFromDiskMemory(key: cacheFilekey ?? "", cacheQueryCompletedBlock: { [weak self] (data, hasCache) in
            DispatchQueue.main.async { [weak self] in
                // 判断是否有缓存，创建数据源地址
                if hasCache {
                    self?.sourceURL = URL(fileURLWithPath: data as? String ?? "")
                } else {
                    self?.sourceURL = self?.sourceURL?.absoluteString.urlScheme(scheme: "streaming")
                }
                // 创建播放器
                if let url = self?.sourceURL {
                    self?.urlAsset = AVURLAsset(url: url, options: nil)
                    self?.urlAsset?.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
                    if let asset = self?.urlAsset {
                        self?.playerItem = AVPlayerItem(asset: asset)
                        self?.playerItem?.addObserver(self!, forKeyPath: "status", options: [.initial, .new], context: nil)
                        self?.player = AVPlayer(playerItem: self?.playerItem)
                        self?.playerLayer.player = self?.player
                        self?.addProgressObserver()
                    }
                }
            }
            }, exten: "mp4")
    }
    
    /// 取消加载
    func cancelLoading() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer.isHidden = true
        CATransaction.commit()
        
        queryCacheOperation?.cancel()
        removeObserver()
        pause()
                
        player = nil
        playerItem = nil
        playerLayer.player = nil
        
        cancelLoadingQueue?.async { [weak self] in
            self?.task?.cancel()
            self?.task = nil
            self?.data = nil
            self?.response = nil
            
            for loadingRequest in self?.pendingRequests ?? [] {
                if !loadingRequest.isFinished {
                    loadingRequest.finishLoading()
                }
            }
            self?.pendingRequests.removeAll()
        }
    }
    
    func play() {
        AVPlayerManager.shared().play(player: player!)
    }
    
    func pause() {
        AVPlayerManager.shared().pause(player: player!)
    }
    
    func replay() {
        AVPlayerManager.shared().replay(player: player!)
    }
    
    deinit {
        removeObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let httpResponse = dataTask.response as! HTTPURLResponse
        let code = httpResponse.statusCode
        if code == 200 {
            completionHandler(URLSession.ResponseDisposition.allow)
            self.data = Data()
            self.response = httpResponse
            self.progressPendingRequest()
        } else {
            completionHandler(URLSession.ResponseDisposition.cancel)
        }
    }
    
    /// 接收下载数据
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.data?.append(data)
        self.progressPendingRequest()
    }
    
    /// 下载完成
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
            WebCacheManager.shared().storeDataToDiskCache(data: self.data, key: self.cacheFilekey ?? "", exten: "mp4")
        } else {
            print("下载失败" + error.debugDescription)
        }
    }
    
    /// 获取网络缓存的数据
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        let cachedResponse = proposedResponse
        // 判断同一个下载地址及缓存方式是否本地
        if dataTask.currentRequest?.cachePolicy == NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData || dataTask.currentRequest?.url?.absoluteString == self.task?.currentRequest?.url?.absoluteString {
            completionHandler(nil)
        } else {
            completionHandler(cachedResponse)
        }
    }
    
    /// 下载进行中处理 request （处理下载数据等等）
    func progressPendingRequest() {
        var requestsCompleted = [AVAssetResourceLoadingRequest]()
        for loadingRequest in self.pendingRequests {
            let didRespondCompletely = respondWithDataForRequest(loadingRequest: loadingRequest)
            if didRespondCompletely {
                requestsCompleted.append(loadingRequest)
                loadingRequest.finishLoading()
            }
        }
        for completedRequest in requestsCompleted {
            if let index = pendingRequests.firstIndex(of: completedRequest) {
                pendingRequests.remove(at: index)
            }
        }
    }
    
    /// 拼接数据
    func respondWithDataForRequest(loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        let mimeType = self.response?.mimeType ?? ""
        let contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
        loadingRequest.contentInformationRequest?.contentType = contentType?.takeRetainedValue() as String?
        loadingRequest.contentInformationRequest?.contentLength = (self.response?.expectedContentLength)!
        
        var startOffset: Int64 = loadingRequest.dataRequest?.requestedOffset ?? 0
        if loadingRequest.dataRequest?.currentOffset != 0 {
            startOffset = loadingRequest.dataRequest?.currentOffset ?? 0
        }
        
        if Int64(data?.count ?? 0) < startOffset {
            return false
        }
        
        let unreadBytes: Int64 = Int64(data?.count ?? 0) - startOffset
        let numberOfBytesToRespondWidth: Int64 = min(Int64(loadingRequest.dataRequest?.requestedLength ?? 0), unreadBytes)
        if let subdata = (data?.subdata(in: Int(startOffset)..<Int(startOffset + numberOfBytesToRespondWidth))) {
            loadingRequest.dataRequest?.respond(with: subdata)
            let endOffset: Int64 = startOffset + Int64(loadingRequest.dataRequest?.requestedLength ?? 0)
            return Int64(data?.count ?? 0) >= endOffset
        }
        return false
    }
}

// MARK: - AVAssetResourceLoaderDelegate（边下边播缓存代理回调）
extension AVPlayerView: AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        if task == nil {
            if let url = loadingRequest.request.url?.absoluteString.urlScheme(scheme: sourceScheme ?? "http") {
                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
                task = session?.dataTask(with: request)
                task?.resume()
            }
        }
        pendingRequests.append(loadingRequest)
        return true
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        if let index = pendingRequests.firstIndex(of: loadingRequest) {
            pendingRequests.remove(at: index)
        }
    }
}
