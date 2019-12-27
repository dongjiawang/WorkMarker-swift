//
//  TemplateBuildView.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/27.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit
import Photos

class TemplateBuildView: UIView {

    var contentImageView = UIImageView()
    var textView = UITextView()
    var textViewFont: CGFloat = 34
    var plachholderLabel = UILabel()
       
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        self.addSubview(self.contentImageView)
        self.contentImageView.snp.makeConstraints({ (make) in
            make.edges.equalTo(self)
        })
                
        self.textView.backgroundColor = .clear
        self.textView.textAlignment = .center
        self.textView.textColor = .white
        self.textView.font = UIFont.systemFont(ofSize: self.textViewFont)
        self.textView.delegate = self
        self.addSubview(self.textView)
        self.textView.snp.makeConstraints({ (make) in
            make.left.top.equalTo(5)
            make.right.bottom.equalTo(-5)
        })
        
        self.plachholderLabel.textColor = .lightGray
        self.plachholderLabel.font = UIFont.systemFont(ofSize: 20)
        self.plachholderLabel.textAlignment = .center
        self.plachholderLabel.text = "点击编辑文字"
        self.addSubview(self.plachholderLabel)
        self.plachholderLabel.snp.makeConstraints { (make) in
            make.center.width.equalTo(self.textView)
            make.height.equalTo(40)
        }
    }
        
    typealias finishTemplateBuild = (_ photoModel: PhotoModel) -> Void
    /// 完成模板制作
    /// - Parameter finishBlock: 成功回调，包含数据模型
    func finishedTemplateBuild(finishBlock: @escaping finishTemplateBuild) {
        self.textView.layer.borderColor = UIColor.clear.cgColor
        self.textView.layer.borderWidth = 0
        self.textView.resignFirstResponder()
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.backgroundColor = .white
        var imageIds = [String]()
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image!)
            imageIds.append(request.placeholderForCreatedAsset!.localIdentifier)
        }) { (success, error) in
            if success {
                let result = PHAsset.fetchAssets(withLocalIdentifiers: imageIds, options: nil)
                result.enumerateObjects { (obj, index, stop) in
                    let model = PhotoModel()
                    model.photoAsset = obj
                    model.localIdentifiter = obj.localIdentifier
                    model.isSelected = true
                    model.originalImage = image
                    DispatchQueue.main.async {
                        finishBlock(model)
                    }
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TemplateBuildView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.plachholderLabel.isHidden = true
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.plachholderLabel.isHidden = textView.hasText
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if self.textViewFont <= 14 {
            WMHUD.textHUD(text: "输入的文字太长了", delay: 1)
            return false
        }
        
        return true
    }
    
    func contentSizeToFit(textView: UITextView) {
        if textView.hasText {
            textView.textContainerInset = .zero
            
            var contentSize = textView.contentSize
            var offset = UIEdgeInsets.zero
            
            if contentSize.height <= textView.frame.height {
                offset.top = (textView.frame.height - contentSize.height) / 2
            } else {
                while (contentSize.height > textView.frame.height) {
                    self.textViewFont -= 1
                    textView.font = UIFont.systemFont(ofSize: self.textViewFont)
                    contentSize = textView.contentSize
                }
            }
            textView.contentInset = offset
        }
    }
}
