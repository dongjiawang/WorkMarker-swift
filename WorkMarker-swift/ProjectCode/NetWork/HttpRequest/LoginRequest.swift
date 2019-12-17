//
//  LoginRequest.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/17.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class LoginRequest: BaseRequest {
    var name: String?
    var pwd: String?
    var siteId: String?
    
    static func login(name: String, pwd: String, siteId: String, success: @escaping HttpSuccess, failure: @escaping HttpFailure) {
        let request = LoginRequest()
        request.name = name
        request.pwd = pwd
        request.siteId = siteId
        NetWorkManager.post(url: URLForLogin, request: request, showHUD: true, success: { (data) in
            if let response = LoginResponse.deserialize(from: data as? [String: Any]) {
                user = response.user
                userToken = response.userToken
                isLogin = true
                
                success(response)
            }
        }) { (error) in
            failure(error)
        }
        
    }
}
