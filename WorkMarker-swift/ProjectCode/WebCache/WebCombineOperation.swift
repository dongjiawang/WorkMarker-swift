//
//  WebCombineOperation.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/12.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class WebCombineOperation: NSObject {
    
    /// 取消下载后回调
    var cancelBlock: WebDownloaderCancelBlock?
    /// 查询缓存任务
    var cacheOperation: Operation?
    /// 下载任务
    var downloadOperation: WebDownloadOperation?
    
    func cancel() {
        
        if cacheOperation != nil {
            cacheOperation?.cancel()
            cacheOperation = nil
        }
        
        if downloadOperation != nil {
            downloadOperation?.cancel()
            downloadOperation = nil
        }
        
        if cancelBlock != nil {
            cancelBlock?()
            cancelBlock = nil
        }
    }
    
}
