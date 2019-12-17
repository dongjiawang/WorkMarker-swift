//
//  Constants.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/11.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import Foundation
import UIKit

// MARK: - 请求地址
let BaseUrl: String = "http://ugcdev.qimooc.net/"
/// 公共上传接口
let URLForUpload = "api/upload/file"
/// 登录接口
let URLForLogin = "api/login"

/// 首页登录后的列表
let URLForHomePageLearner = "api/learner/ugc/courses"
/// 未登录
let URLForHomePageOpen = "api/open/ugc/courses"







// MARK: - 颜色
func RGBA(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a);
}
/// app主题色
let ColorTheme: UIColor = RGBA(r: 246, g: 124, b: 30, a: 1)
/// 默认背景色
let ColorThemeBackground: UIColor = RGBA(r: 243, g: 245, b: 242, a: 1)


