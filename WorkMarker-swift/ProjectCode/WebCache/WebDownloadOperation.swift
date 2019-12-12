//
//  WebDownloadOperation.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/12.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class WebDownloadOperation: Operation {
    // 回调
    var progressBlock: WebDownloaderProgressBlock?
    var completedBlock: WebDownloaderCompletedBlock?
    var cancelBlock: WebDownloaderCancelBlock?
    
    // 网络请求
    var session: URLSession?
    var dataTask: URLSessionTask?
    var request: URLRequest?
    
    // 数据
    var imageData: Data?
    var expectedSize: Int64?
    
    // 记录任务是否执行
    var _executing: Bool = false
    // 任务是否完成
    var _finished: Bool = false
    
    init(request: URLRequest, progress: @escaping WebDownloaderProgressBlock, compeleted: @escaping WebDownloaderCompletedBlock, cancel: @escaping WebDownloaderCancelBlock) {
        super.init()
        
        self.request = request
        self.progressBlock = progress
        self.completedBlock = compeleted
        self.cancelBlock = cancel
    }
    
    override func start() {
        willChangeValue(forKey: "isExecuting")
        _executing = true
        didChangeValue(forKey: "isExecuting")
        
        // 判断是否取消了任务
        if self.isCancelled {
            done()
            return
        }
        
        // 设置超时
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 15
        
        session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        dataTask = session?.dataTask(with: request!)
        dataTask?.resume()
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override func cancel() {
        objc_sync_enter(self)
        done()
        objc_sync_exit(self)
    }
    
    func done() {
        super.cancel()
        if _executing {
            willChangeValue(forKey: "isFinished")
            willChangeValue(forKey: "isExecuting")
            _finished = true
            _executing = false
            didChangeValue(forKey: "isFinished")
            didChangeValue(forKey: "isExecuting")
            // 重置
            reset()
        }
    }
    
    func reset() {
        if dataTask != nil {
            dataTask?.cancel()
        }
        if session != nil {
            session?.invalidateAndCancel()
            session = nil
        }
    }
}

// MARK: - URLSession 的回调
extension WebDownloadOperation: URLSessionDataDelegate, URLSessionDelegate {
    /// 获取响应
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let httpResponse = dataTask.response as! HTTPURLResponse
        let code = httpResponse.statusCode
        if code == 200 {
            completionHandler(URLSession.ResponseDisposition.allow)
            imageData = Data()
            expectedSize = httpResponse.expectedContentLength
        } else {
            completionHandler(URLSession.ResponseDisposition.cancel)
        }
    }
    /// 下载完毕
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if completedBlock != nil {
            if error != nil {
                let err = error! as NSError
                if err.code == NSURLErrorCancelled {
                    cancelBlock?()
                } else {
                    completedBlock?(nil, error, false)
                }
            } else {
                completedBlock?(imageData!, nil, true)
            }
        }
        done()
    }
    /// 接收数据,并更新下载进度
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        imageData?.append(data)
        if progressBlock != nil {
            progressBlock?(Int64(imageData?.count ?? 0), expectedSize ?? 0)
        }
    }
    
    /// 复用本地缓存的数据
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        let cacheResponse = proposedResponse
        if request?.cachePolicy == NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData {
            completionHandler(nil)
            return
        }
        completionHandler(cacheResponse)
    }
}
