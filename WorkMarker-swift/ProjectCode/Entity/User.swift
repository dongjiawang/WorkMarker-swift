//
//  User.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/16.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class User: BaseModel {

    var id: Double?
    var userAvatar: UserAvatar?
    var lastName: String?
    var firstName: String?
    var isSystemUser: Bool?
    var sex: String?
    var startDate: Double?
    var status: String?
    var userGroup: UserGroup?
    var endDate: Double?
    var avatar: String?
    var language: String?
    var signatureInfo: String?
    var site: Site?
    var username: String?
    var defaultRole: String?
    var email: String?
    var displayName: String?
    var phoneNumber: String?
}
