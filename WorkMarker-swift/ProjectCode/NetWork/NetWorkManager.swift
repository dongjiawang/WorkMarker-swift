//
//  NetWorkManager.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/13.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

let NetworkStatesChangeNotification = "NetworkStatesChangeNotification"

/// 网络请求数据类型
enum NetworkRequestContentType {
    case NONE
    case JSON
    case TEXT
    case ZIP
    case MP4
    case JPG
}

/// 请求方式
enum NetworkMethod {
    case GET
    case POST
    case PUT
    case DELETE
}

typealias HttpSuccess = (_ data: Any) -> Void
typealias HttpFailure = (_ error: Error) -> Void
typealias UploadProgress = (_ percent: CGFloat) -> Void

class NetWorkManager: NSObject {
    private static let reachiabilityManager = { () -> NetworkReachabilityManager in
        let manager = NetworkReachabilityManager()
        return manager!
    }()
    
    private static let sessionManager = { () -> SessionManager in
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 10 // 超时 10s
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData // 关闭缓存
        let manager = SessionManager(configuration: sessionConfiguration)
        /// https 证书验证
        manager.delegate.sessionDidReceiveChallenge = { session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            } else {
                credential = manager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                if credential != nil {
                    disposition = .useCredential
                }
            }
            return (disposition, credential)
        }
        return manager
    }()
}
// MARK: - 对外使用的方式，更简洁的使用
extension NetWorkManager {
    /// get 请求
    static func get(url: String, request: BaseRequest, showHUD: Bool, success: @escaping HttpSuccess, failure: @escaping HttpFailure) {
        startRequest(url: url, request: request, method: .get, contentType: .NONE, showHUD: showHUD, success: success, failure: failure)
    }
    /// post 请求
    static func post(url: String, request: BaseRequest, showHUD: Bool, success: @escaping HttpSuccess, failure: @escaping HttpFailure) {
        startRequest(url: url, request: request, method: .post, contentType: .NONE, showHUD: showHUD, success: success, failure: failure)
    }
    /// delete 请求
    static func delete(url: String, request: BaseRequest, showHUD: Bool, success: @escaping HttpSuccess, failure: @escaping HttpFailure) {
        startRequest(url: url, request: request, method: .delete, contentType: .NONE, showHUD: showHUD, success: success, failure: failure)
    }
    /// 上传文件方法
    ///
    /// 这个方法比较特殊，所以 manager 都是重新创建的，跟常用的请求分开
    static func postData(url: String, contentType: NetworkRequestContentType, request: BaseRequest, showHUD: Bool, fileData: Any?, success: @escaping HttpSuccess, failure: @escaping HttpFailure) {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 600 // 超时 10分钟
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData // 关闭缓存
        let manager = SessionManager(configuration: sessionConfiguration)
        let headers = requestHeader()
        let parameters = request.toJSON()
        var content: [String]
        if contentType == .ZIP {
            content = ["application/zip; charset=utf-8", "application/json"]
        } else if contentType == .MP4 {
            content = ["application/json", "multipart/form-data"]
        } else if contentType == .JPG {
            content = ["text/plain", ""]
        } else {
            content = ["text/plain", "application/zip; charset=utf-8"]
        }
        
        if showHUD {
            HUD.show(.systemActivity)
        }
        let sessionRequest = manager.request(url.splicingRequestURL(), method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
        sessionRequest.validate(contentType: content)
        sessionRequest.responseJSON { (response) in
            HUD.hide()
            requestComplete(response: response, success: success, failure: failure)
        }
    }
    
    /// 取消请求
    static func cancelAllOperations() {
        sessionManager.session.invalidateAndCancel()
    }
}

// MARK: - 封装的基础网络请求
extension NetWorkManager {
    
    /// 开始一个请求
    /// - Parameters:
    ///   - url: 请求地址
    ///   - request: 请求类型
    ///   - method: 请求方式
    ///   - contentType: contentType
    ///   - showHUD: 是否显示 HUD
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func startRequest(url: String, request: BaseRequest, method: HTTPMethod, contentType: NetworkRequestContentType, showHUD: Bool, success: @escaping HttpSuccess, failure: @escaping HttpFailure) {
        
        let parameters = request.toJSON()
        let requestContentType = switchRequestContentType(contentType: contentType)
        let headers = requestHeader()
        if showHUD {
            HUD.show(.systemActivity)            
        }
                
        let sessionRequest = sessionManager.request(url.splicingRequestURL(), method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers)
        sessionRequest.validate(contentType: requestContentType)
        sessionRequest.responseJSON { (response) in
            HUD.hide()
            requestComplete(response: response, success: success, failure: failure)
        }
    }
    /// 请求完毕回调，处理成功或者失败
    static func requestComplete(response: DataResponse<Any>, success: @escaping HttpSuccess, failure: @escaping HttpFailure) {
        switch response.result {
        case .success:
            let data:[String: Any] = response.result.value as! [String : Any]
            success(data)
            break
        case .failure(let error):
            let err: NSError = error as NSError
            if reachiabilityManager.networkReachabilityStatus == .notReachable {
                failure(err)
                return
            }
            
            var message: String = err.localizedDescription
            if message == "No message available" {
                message = ""
            }
            if err.code == 401 {
                message = "重新登录"
            } else if err.code == 502 {
                message = "服务器停止运行"
            } else if err.code == 500 {
                if message.count > 30 {
                    message = "网络连接错误！"
                }
            } else {
                if message.count == 0 {
                    if response.request?.url?.absoluteString == nil && err.localizedDescription.contains("timed out") {
                        message = "请求超时，请稍后重试！"
                    } else {
                        message = ("接口异常，接口名称：" + (response.request?.url!.relativePath)!  + "错误码:\(err.code)")
                    }
                }
            }
            if message.count > 1 {
                HUD.flash(HUDContentType.label(message), delay: 3)
            }
            failure(err)
            
            break
        }
    }
    /// 判断contentType
    static func switchRequestContentType(contentType: NetworkRequestContentType) -> [String] {
        switch contentType {
        case .NONE, .TEXT, .ZIP:
            return ["application/x-www-form-urlencoded;charset=utf-8"]
        case .JSON:
            return ["application/json"]
        default:
            return ["application/x-www-form-urlencoded;charset=utf-8"]
        }
    }
}

// MARK: - header参数部分
extension NetWorkManager {
    static func requestHeader() -> HTTPHeaders {
        let headers = ["X-Requested-With" : "XMLHttpRequest",
                       "Referer" : BaseUrl,
                       "User-Agent" : userAgent()]
        
        return headers;
    }
    
    static func userAgent() -> String {
        let appVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let systemVersion: String = UIDevice.current.systemVersion
        
        return "Mozilla/5.0 (iPhone; CPU iPhone OS" + systemVersion + " like Mac OS X) AppleWebKit/603.2.4 (KHTML, like Gecko) Mobile/14F89  CourseMaker/" + appVersion
    }
}


// MARK: - Reachiability
extension NetWorkManager {
    
    /// 开始监控网络状态
    static func startMonitoring() {
        reachiabilityManager.startListening()
        reachiabilityManager.listener = { status in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NetworkStatesChangeNotification), object: status)
        }
    }
    
    /// 网络状态
    static func networkStatus() -> NetworkReachabilityManager.NetworkReachabilityStatus {
        return reachiabilityManager.networkReachabilityStatus;
    }
    
    /// 是否正常联网
    static func isNotReachableStatus(status : Any?) -> Bool {
        let netStatus = status as! NetworkReachabilityManager.NetworkReachabilityStatus
        return netStatus == .notReachable
    }
}
