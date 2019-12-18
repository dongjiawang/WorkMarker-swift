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
    var id: String?
    var displayName: String?
    var image: UIImage?
    var file: String?
    
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
    
    static func updateUserInfo(name: String, userID: String, success: @escaping HttpSuccess, failure: @escaping HttpFailure) {
        let request = PersonalRequest()
        request.id = userID
        request.displayName = name
        NetWorkManager.post(url: URLForUpdateUserInfo, request: request, showHUD: true, success: { (data) in
            success(data)
        }) { (error) in
            failure(error)
        }
    }
    
    static func uploadUserIcon(image: UIImage, userId: String, success: @escaping HttpSuccess, failure: @escaping HttpFailure) {
        let request = PersonalRequest()
        request.id = userId
        request.file = "userAvatar.jpg"
        let url = URLForUploadUserAvatar + userId
        let imageData = image.jpegData(compressionQuality: 0.5)
        
        NetWorkManager.postData(url: url, contentType: .JPG, request: request, showHUD: true, fileData: imageData, success: { (data) in
            success(data)
        }) { (error) in
            failure(error)
        }
        
        
    }
}
