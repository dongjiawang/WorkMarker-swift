//
//  PhotoAssetActionPreview.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/27.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class PhotoAssetActionPreview: UIImageView {

    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.label.text = "点击编辑文字"
        self.label.textAlignment = .center
        self.label.textColor = .lightGray
        self.label.font = UIFont.systemFont(ofSize: 20)
        self.label.layer.borderColor = UIColor.lightGray.cgColor
        self.label.layer.borderWidth = 0.5
        self.addSubview(self.label)
        self.label.snp.makeConstraints { (make) in
            make.top.left.equalTo(5)
            make.bottom.right.equalTo(-5)
        }
        
        self.backgroundColor = .white
        
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(beginEditText))
        self.label.addGestureRecognizer(tap)
    }
    
    typealias beginEdit = () -> Void
    var beginEditBlock: beginEdit?
    @objc func beginEditText() {
        if beginEditBlock != nil {
            beginEditBlock!()
        }
    }
    
    var preImage: UIImage? {
        set {
            self.image = newValue
            if newValue == nil {
                self.label.isHidden = true
                self.backgroundColor = .white
            } else {
                self.label.isHidden = false
                self.backgroundColor = .black
            }
        }
        get {
            return self.image
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
