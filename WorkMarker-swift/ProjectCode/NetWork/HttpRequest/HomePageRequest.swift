//
//  HomePageRequest.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/13.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class HomePageRequest: BaseRequest {
    var page:Int?
    var size:Int?
    
    static func requestCourseList(page: Int, size: Int, success: @escaping HttpSuccess, failure: @escaping HttpFailure) {
        let request = HomePageRequest()
        request.page = page
        request.size = size
        NetWorkManager.get(url: isLogin ? URLForHomePageLearner : URLForHomePageOpen, request: request, showHUD: true, success: { (data) in
            if let response = HomePageCourseListResponse.deserialize(from: data as? [String: Any]) {
                success(response)
            }
        }) { (error) in
            failure(error)
        }
    }
}
