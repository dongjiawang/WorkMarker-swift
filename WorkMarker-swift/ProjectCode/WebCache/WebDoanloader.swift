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
    
    func download(url: URL, progress: @escaping WebDownloaderProgressBlock, completed: @escaping WebDownloaderCompletedBlock, cancel: @escaping WebDownloaderCancelBlock) -> WebCombineOperation {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        request.httpShouldUsePipelining = true
        let key = url.absoluteString
        let operation = WebCombineOperation.init()
        
        
        
    }
}
