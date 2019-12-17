//
//  LoginViewController.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/17.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

typealias loginSucess = () -> Void

class LoginViewController: BaseViewController {
            
    var loginSucessBlock: loginSucess?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let loginView = LoginView(frame: self.view.bounds)
        self.view.addSubview(loginView)
        
        loginView.beginLoginBlock = {name, pwd in
            
        }
        
        let closeBtn = UIButton(type: .custom)
        closeBtn.setImage(UIImage(named: "透明关闭"), for: .normal)
        closeBtn.addTarget(self, action: #selector(clickedCloseBtn), for: .touchUpInside)
        self.view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(30)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    @objc func clickedCloseBtn() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func login(name: String, pwd: String, siteId: String) {
        LoginRequest.login(name: name, pwd: pwd, siteId: "1", success: { (data) in
                if self.loginSucessBlock != nil {
                    self.loginSucessBlock!()
                }
                self.clickedCloseBtn()
        }) { (error) in
            
        }
    }
}
