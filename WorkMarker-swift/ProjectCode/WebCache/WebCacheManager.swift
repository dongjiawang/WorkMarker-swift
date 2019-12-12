//
//  WebCacheManager.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/12.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit
import CommonCrypto

/// 缓存清除完毕后回调
typealias WebCacheClearCompletedBlock = (_ cacheSize: String) -> Void

/// 缓存查询完毕后回调
typealias WebCacheQueryCompletedBlock = (_ data: Any?, _ hasCache: Bool) -> Void

/// 下载进度回调
typealias WebDownloaderProgressBlock = (_ receivedSize: Int64, _ expectedSize: Int64) -> Void

/// 下载完毕回调
typealias WebDownloaderCompletedBlock = (_ data: Data?, _ error: Error?, _ finished: Bool) -> Void

/// 下载取消回调
typealias WebDownloaderCancelBlock = () -> Void

class WebCacheManager: NSObject {
    var memCache: NSCache<NSString, AnyObject>?
    var fileManager: FileManager = FileManager.default
    var diskCacheDirectoryURL: URL?
    var ioQueue: DispatchQueue?
    
    private static let instance = { () -> WebCacheManager in
        return WebCacheManager.init()
    }()
    
    class func shared() -> WebCacheManager {
        return instance
    }
    
    private override init() {
        super.init()
        
        self.memCache = NSCache()
        self.memCache?.name = "webCache"
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths.last
        let diskCachePath = path! + "/webCache"
        
        var isDirectory: ObjCBool = false
        let isExisted = fileManager.fileExists(atPath: diskCachePath, isDirectory: &isDirectory)
        // 判断是否存在缓存文件夹
        if !isDirectory.boolValue || !isExisted {
            do {
                try fileManager.createDirectory(atPath: diskCachePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("创建缓存路径失败" + error.localizedDescription)
            }
        }
        diskCacheDirectoryURL = URL(fileURLWithPath: diskCachePath)
        ioQueue = DispatchQueue(label: "com.start.webcache")
    }
    // MARK: - 查询数据
    /// 从内存和磁盘中查询数据
    /// - Parameters:
    ///   - key: key 值
    ///   - cacheQueryCompletedBlock: 查询完毕后回调
    func queryDataFromMemory(key: String, cacheQueryCompletedBlock: @escaping WebCacheQueryCompletedBlock) -> Operation {
        return queryDataFromMemory(key: key, cacheQueryCompletedBlock: cacheQueryCompletedBlock, exten: nil)
    }
    /// 从内存和磁盘中查询数据
    /// - Parameters:
    ///   - key: key 值
    ///   - cacheQueryCompletedBlock: 查询完毕后回调
    ///   - exten: 范围
    func queryDataFromMemory(key: String, cacheQueryCompletedBlock: @escaping WebCacheQueryCompletedBlock, exten: String?) -> Operation {
        let operation = Operation()
        ioQueue?.sync {
            if operation.isCancelled {
                return
            }
            /// 分别从内存或磁盘获取数据
            if let data = self.dataFromMemoryCache(key: key) {
                cacheQueryCompletedBlock(data, true)
            } else if let data = self.dataFromDiskCache(key: key, exten: exten) {
                storeDataToMemoryCache(data: data, key: key)
                cacheQueryCompletedBlock(data, true)
            } else {
                cacheQueryCompletedBlock(nil, false)
            }
        }
        
        return operation
    }
    
    /// 根据URL查询缓存数据
    /// - Parameters:
    ///   - key: key 值
    ///   - cacheQueryCompletedBlock: 查询完毕后回调
    func queryURLFromDiskMemory(key: String, cacheQueryCompletedBlock: @escaping WebCacheQueryCompletedBlock) -> Operation {
        return queryURLFromDiskMemory(key: key, cacheQueryCompletedBlock: cacheQueryCompletedBlock, exten: nil)
    }
    
    /// 根据URL查询缓存数据
    /// - Parameters:
    ///   - key: key 值
    ///   - cacheQueryCompletedBlock: 查询完毕后回调
    ///   - exten: 范围
    func queryURLFromDiskMemory(key: String, cacheQueryCompletedBlock: @escaping WebCacheQueryCompletedBlock, exten: String?) -> Operation {
        let operation = Operation()
        ioQueue?.sync {
            if operation.isCancelled {
                return;
            }
            let path = diskCachePathForKey(key: key, exten: exten) ?? ""
            if fileManager.fileExists(atPath: path) {
                cacheQueryCompletedBlock(path, true)
            } else {
                cacheQueryCompletedBlock(path, false)
            }
        }
        return operation
    }
    
    // MARK: - 存储数据
    func storeDataCache(data: Data?, key: String) {
        ioQueue?.async {
            self.storeDataToMemoryCache(data: data, key: key)
            self.storeDataToDiskCache(data: data, key: key)
        }
    }
    /// 存储数据到内存
    /// - Parameters:
    ///   - data: 数据
    ///   - key: key 值
    func storeDataToMemoryCache(data: Data?, key: String) {
        memCache?.setObject(data as AnyObject, forKey: key as NSString)
    }
    /// 存储数据到磁盘
    /// - Parameters:
    ///   - data: <#data description#>
    ///   - key: <#key description#>
    func storeDataToDiskCache(data: Data?, key: String) {
        self.storeDataToDiskCache(data: data, key: key, exten: nil)
    }
    
    /// 存储数据到磁盘
    /// - Parameters:
    ///   - data: 数据
    ///   - key: key 值
    ///   - exten: 范围
    func storeDataToDiskCache(data: Data?, key: String, exten: String?) {
        if let diskPath = diskCachePathForKey(key: key, exten: exten) {
            fileManager.createFile(atPath: diskPath, contents: data, attributes: nil)
        }
    }
    
    // MARK: - 获取内存缓存
    /// 根据 key 从内存中查询缓存
    /// - Parameter key: key 值
    func dataFromMemoryCache(key: String) -> Data? {
        return memCache?.object(forKey: key as NSString) as? Data
    }
    // MARK: - 获取磁盘缓存
    /// 根据 key 获取本地磁盘缓存数据
    /// - Parameter key: key 值
    func dataFromDiskCache(key: String) -> Data? {
        return dataFromDiskCache(key: key, exten: nil)
    }
    
    /// 根据 key 获取本地磁盘缓存数据
    /// - Parameters:
    ///   - key: key 值
    ///   - exten: 长度
    func dataFromDiskCache(key: String, exten: String?) -> Data? {
        if let cachePathForKey = diskCachePathForKey(key: key, exten: exten) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: cachePathForKey))
                return data
            } catch {}
        }
        return nil
    }
    
    // MARK: - 获取文件路径
    /// 获取 key 值对应的磁盘缓存路径 （包含扩展名）
    /// - Parameters:
    ///   - key: key 值
    ///   - exten: 路径
    func diskCachePathForKey(key: String, exten: String?) -> String? {
        let fileName = key.sha256()
        var cachePathForKey = diskCacheDirectoryURL?.appendingPathComponent(fileName).path
        if exten != nil {
            cachePathForKey = cachePathForKey! + "." + exten!
        }
        return cachePathForKey
    }
    // MARK: - 清除缓存
    /// 清理缓存
    func clearCache(cacheClearCompletedBlock: @escaping WebCacheClearCompletedBlock) {
        ioQueue?.async {
            self.clearMemoryCache()
            let cacheSize = self.clearDiskCache()
            DispatchQueue.main.async {
                cacheClearCompletedBlock(cacheSize)
            }
            
        }
    }
    /// 清除内存中的缓存
    func clearMemoryCache() {
        memCache?.removeAllObjects()
    }
    
    /// 清理磁盘缓存
    func clearDiskCache() -> String {
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: (diskCacheDirectoryURL?.path)!)
            var folderSize: Float = 0
            for fileName in contents {
                let filePath = (diskCacheDirectoryURL?.path)! + "/" + fileName
                let fileDict = try fileManager.attributesOfItem(atPath: filePath)
                folderSize += fileDict[FileAttributeKey.size] as! Float
                try fileManager.removeItem(atPath: filePath)
            }
            return String.format(decimal: folderSize / 1024.0 / 1024.0) ?? "0"
        } catch {
            print("清理磁盘错误" + error.localizedDescription)
        }
        return "0"
    }
    
    
}
