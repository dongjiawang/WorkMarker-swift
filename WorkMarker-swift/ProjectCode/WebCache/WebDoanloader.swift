//
//  WebDoanloader.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/12.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class WebDoanloader: NSObject {

    var downloadQueue: OperationQueue?
    
    private static let instance = { () -> WebDoanloader in
        return WebDoanloader.init()
    }()
    
    class func shared() -> WebDoanloader {
        return instance
    }
    
    /// 下载资源数据
    /// - Parameters:
    ///   - url: 资源地址
    ///   - progress: 进度回调
    ///   - completed: 成功回调
    ///   - cancel: 取消回调
    func download(url: URL, progress: @escaping WebDownloaderProgressBlock, completed: @escaping WebDownloaderCompletedBlock, cancel: @escaping WebDownloaderCancelBlock) -> WebCombineOperation {
        // 创建数据请求
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        request.httpShouldUsePipelining = true
        // 使用url做数据到key 值
        let key = url.absoluteString
        // 创建下载进程
        let operation = WebCombineOperation.init()
        // 先获取是否本地缓存
        operation.cacheOperation = WebCacheManager.shared().queryDataFromMemory(key: key, cacheQueryCompletedBlock: { [weak self] (data, hasCache) in
            if hasCache {
                completed(data as? Data, nil, true)
            } else {
                // 没有本地缓存，开启下载进程
                let downloadOperation = WebDownloadOperation.init(request: request, progress: progress, compeleted: { (data, error, finished) in
                    if finished && error == nil {
                        // 下载完成，保存数据
                        WebCacheManager.shared().storeDataCache(data: data, key: key)
                        completed(data, nil, true)
                    } else {
                        completed(data, error, false)
                    }
                }, cancel: {
                    cancel()
                })
                operation.downloadOperation = downloadOperation
                self?.downloadQueue?.addOperation(downloadOperation)
            }
        })
        return operation
    }
}
