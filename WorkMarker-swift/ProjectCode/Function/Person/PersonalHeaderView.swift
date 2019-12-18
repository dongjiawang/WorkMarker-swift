//
//  PersonalHeaderView.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/18.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class PersonalHeaderView: UIView {

    var settingBtn = UIButton(type: .custom)
    var userImage = UIButton()
    var nameLabel = UILabel()
    var editBtn = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        self.settingBtn.setImage(UIImage(named: "settingBtn"), for: .normal)
        self.settingBtn.addTarget(self, action: #selector(clickedSettingBtn), for: .touchUpOutside)
        self.addSubview(self.settingBtn)
        self.settingBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 44, height: 44))
            make.right.equalTo(-10)
            let top = UIDevice.current.isiPhoneXMore() ? 40 : 20
            make.top.equalTo(top)
        }
        
        self.userImage.clipsToBounds = true
        self.userImage.layer.cornerRadius = 40
        self.userImage.setImage(UIImage(named: "userIcon"), for: .normal)
        self.userImage.addTarget(self, action: #selector(clickedUserImage), for: .touchUpInside)
        self.addSubview(self.userImage)
        self.userImage.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.size.equalTo(CGSize(width: 80, height: 80))
            make.bottom.equalTo(-40)
        }
        
        self.nameLabel.font = UIFont.systemFont(ofSize: 14)
        self.nameLabel.textColor = .white
        self.nameLabel.textAlignment = .center
        self.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.userImage.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(self.userImage.snp.width)
        }
        
        self.editBtn.setImage(UIImage(named: "个人中心_编辑"), for: .normal)
        self.editBtn.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        self.editBtn.addTarget(self, action: #selector(clickedEditBtn), for: .touchUpInside)
        self.addSubview(self.editBtn)
        self.editBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.nameLabel)
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.left.equalTo(self.nameLabel.snp.right)
        }
    }
    

    var editUserNameBlock: (() -> Void)?
    var editUserIconBlock: (() -> Void)?
    var settingAppBlock: (() -> Void)?
    var goBackBlock: (() -> Void)?
    
    func setupUser(user: User) {
        self.userImage.kf.setImage(with: user.avatar?.splicingRequestURL(), for: .normal)
        self.nameLabel.text = user.displayName
    }
    
    @objc func clickedUserImage() {
        if editUserIconBlock != nil {
            editUserIconBlock!()
        }
    }
    
    @objc func clickedEditBtn() {
        if editUserNameBlock != nil {
            editUserNameBlock!()
        }
    }
    
    @objc func clickedSettingBtn() {
        if settingAppBlock != nil {
            settingAppBlock!()
        }
    }
    
    @objc func clickedBackBtn() {
        if goBackBlock != nil {
            goBackBlock!()
        }
    }
    
    lazy var backBtn = { () -> (UIButton) in
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.addTarget(self, action: #selector(clickedBackBtn), for: .touchUpInside)
        self.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 44, height: 44))
            make.left.equalTo(20)
            make.top.equalTo(self.settingBtn)
        }
        
        return btn
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
