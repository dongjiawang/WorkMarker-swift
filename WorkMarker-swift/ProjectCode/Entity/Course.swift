//
//  CourseContentModel.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/16.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class Course: BaseModel {
    var id: Double?
    var likeCount: Double = 0
//    var likeCountString: String?
    var intro: String?
    var lastModifiedDate: Double?
    var chapter: Chapter?
    var createdDate: Double?
    var imageUrl: String?
    var isPublic: Bool?
    var viewCount: Double?
    var commentAgentId: Double?
    var commentCount: Double?
    var isLiked: Bool?
    var hotNum: Double?
    var user: User?
    var name: String?

    var likeCountString: String {
        get {
            if self.likeCount > 10000 {
                return "\((self.likeCount) / 10000)w"
            } else {
                return "\(self.likeCount)"
            }
        }
    }
}
