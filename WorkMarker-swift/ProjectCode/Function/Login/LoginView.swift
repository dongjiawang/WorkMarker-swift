//
//  LoginView.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/17.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit


typealias beginLogin = (_ name: String, _ pwd: String) -> Void

class LoginView: UIView {

    var userImage = UIImageView()
    var nameTextField = UITextField()
    var pwdTextField = UITextField()
    var loginBtn = UIButton(type: .custom)
    var forgotBtn = UIButton(type: .custom)
    var beginLoginBlock: beginLogin?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.userImage.clipsToBounds = true
        self.userImage.layer.cornerRadius = 10
        self.userImage.image = UIImage(named: "userIcon")
        self.addSubview(self.userImage)
        self.userImage.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.size.equalTo(CGSize(width: 70, height: 70))
            make.top.equalTo(150)
        }
        
        let tip = UILabel()
        tip.text = "使用移动学习账号登录"
        tip.font = UIFont.systemFont(ofSize: 14)
        tip.textAlignment = .center
        self.addSubview(tip)
        tip.snp.makeConstraints { (make) in
            make.top.equalTo(self.userImage.snp.bottom).offset(30)
            make.left.right.equalTo(0)
            make.height.equalTo(30)
        }
        
        self.nameTextField.backgroundColor = .white
        self.nameTextField.delegate = self
        self.nameTextField.font = UIFont.systemFont(ofSize: 14)
        self.nameTextField.placeholder = "请输入用户名"
        self.nameTextField.textColor = .darkText
        self.nameTextField.returnKeyType = .done
        self.nameTextField.textAlignment = .center
        self.nameTextField.autocorrectionType = .no
        self.nameTextField.autocapitalizationType = .none
        self.nameTextField.addTarget(self, action: #selector(nameTextFieldChanged), for: .editingChanged)
        self.addSubview(self.nameTextField)
        self.nameTextField.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self.userImage.snp.bottom).offset(120)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(44)
        }
        
        self.pwdTextField.backgroundColor = .white
        self.pwdTextField.delegate = self
        self.pwdTextField.font = UIFont.systemFont(ofSize: 14)
        self.pwdTextField.placeholder = "请输入用户密码"
        self.pwdTextField.textColor = .darkText
        self.pwdTextField.returnKeyType = .done
        self.pwdTextField.isSecureTextEntry = true
        self.pwdTextField.textAlignment = .center
        self.addSubview(self.pwdTextField)
        self.pwdTextField.snp.makeConstraints { (make) in
            make.left.right.centerX.height.equalTo(self.nameTextField)
            make.top.equalTo(self.nameTextField.snp.bottom).offset(1)
        }
        
        self.loginBtn.setTitle("登   录", for: .normal)
        self.loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.loginBtn.setTitleColor(.white, for: .normal)
        self.loginBtn.backgroundColor = ColorTheme
        self.loginBtn.clipsToBounds = true
        self.loginBtn.layer.cornerRadius = 5
        self.loginBtn.addTarget(self, action: #selector(clickedLoginBtn), for: .touchUpInside)
        self.addSubview(self.loginBtn)
        self.loginBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.pwdTextField)
            make.top.equalTo(self.pwdTextField.snp.bottom).offset(50)
            make.height.equalTo(44)
        }
        
        self.forgotBtn.setTitle("忘记密码", for: .normal)
        self.forgotBtn.setTitleColor(.lightGray, for: .normal)
        self.forgotBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.forgotBtn.contentHorizontalAlignment = .right
        self.forgotBtn.addTarget(self, action: #selector(clickedForgetBtn), for: .touchUpInside)
        self.addSubview(self.forgotBtn)
        self.forgotBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.loginBtn)
            make.top.equalTo(self.loginBtn.snp.bottom)
            make.size.equalTo(CGSize(width: 100, height: 30))
        }
    }
    
    @objc func clickedLoginBtn() {
        self.endEditing(true)
        
        let name = self.nameTextField.text?.replacingOccurrences(of: " ", with: "") ?? ""
        let pwd = self.pwdTextField.text?.replacingOccurrences(of: " ", with: "") ?? ""
        
        if name.count == 0 {
            WMHUD.textHUD(text: "请输入用户名", delay: 1)
            return
        }
        if pwd.count == 0 {
            WMHUD.textHUD(text: "请输入用户密码", delay: 1)
            return
        }
        
        if beginLoginBlock != nil {
            beginLoginBlock!(name, pwd)
        }
    }
    
    @objc func clickedForgetBtn() {
        
    }
    
    @objc func nameTextFieldChanged() {
        self.pwdTextField.text = ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LoginView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.clickedLoginBtn()
        return true
    }
}
