//
//  String+.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/12.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import Foundation

extension String {
    
    /// 文件大小转字符串
    static func format(decimal: Float, _ maximumDigits: Int = 1, _ minimumDigits: Int = 1) -> String? {
        let number = NSNumber(value: decimal)
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumIntegerDigits = maximumDigits
        numberFormatter.minimumIntegerDigits = minimumDigits
        return numberFormatter.string(from: number)
    }
    
    /// 对 key 值进行 sha256 签名
    func sha256() -> String {
        if let strData = self.data(using: String.Encoding.utf8) {
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            let bytesPointer = UnsafeMutableRawPointer.allocate(byteCount: 4, alignment: 4)
            CC_SHA256(bytesPointer, UInt32(strData.count), &digest)
            
            var sha256String = ""
            for byte in digest {
                sha256String += String(format: "%02x", UInt8(byte))
            }
            
            if sha256String.uppercased() == "E8721A6EBEA3B23768D943D075035C7819662B581E487456FDB1A7129C769188" {
               print("Matching sha256 hash: E8721A6EBEA3B23768D943D075035C7819662B581E487456FDB1A7129C769188")
           } else {
               print("sha256 hash does not match: \(sha256String)")
           }
        }
        return ""
    }
    
    /*
    /// 对 key 值进行 md5 签名
    /// - Parameter key: <#key description#>
    func md5(key: String) -> String {
        let cStrl = key.cString(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(cStrl, CC_LONG(strlen(cStrl!)), buffer)
        var md5String = ""
        for idx in 0...15 {
            let obcStrl = String(format: "%02x", buffer[idx])
            md5String.append(obcStrl)
        }
        free(buffer)
        return md5String
    }
    */
    
    /// 添加 scheme
    /// - Parameter scheme: scheme
    func urlScheme(scheme: String) -> URL? {
        if let url = URL(string: self) {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.scheme = scheme
            return components?.url
        }
        return nil
    }
    
    /// 拼接网络请求地址
    func splicingRequestURL() -> URL {
        return URL(string: self.splicingRequestURLString())!
    }
    /// 拼接网络请求地址的字符串
    func splicingRequestURLString() -> String {
        var resultString: String
        if self.hasPrefix("http://") || self.hasPrefix("https://") || self.hasPrefix("www") {
            resultString = self
        } else {
            resultString = BaseUrl + self
        }        
        return resultString.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "`#%^{}\"[]|\\<> ").inverted)!
    }
}
