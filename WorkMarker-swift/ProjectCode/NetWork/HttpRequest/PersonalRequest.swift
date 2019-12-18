//
//  PersonalRequest.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/18.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class PersonalRequest: BaseRequest {
    var page:Int?
    var size:Int?
    var userID: String?
    
    static func reqeustCourseList(url: String, page: Int , size: Int, showHUD: Bool, success: @escaping HttpSuccess, failure: @escaping HttpFailure) {
        let request = PersonalRequest()
        request.page = page
        request.size = size
        
        NetWorkManager.get(url: url, request: request, showHUD: showHUD, success: { (data) in
            if let response = PersonalResponse.deserialize(from: data as? [String: Any]) {
                success(response)
            }
        }) { (error) in
            failure(error)
        }        
    }
}
