//
//  MainTabBarViewController.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/11.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    var plusBtn: UIButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tabBar.tintColor = ColorTheme
        self.tabBar.barTintColor = UIColor.clear
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.shadowImage = UIImage()
        self.delegate = self
        
        self.addChildViewControllers()
        self.addPlusBtn(image: UIImage(named: "WorkCourseBtn")!, selectedImage: UIImage(named: "WorkCourseBtn")!)                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    func addChildViewControllers() {
        let home = HomePageViewController()
        self.addTabItem(controller: home, normalImage: UIImage(named: "MainTabarHomeBtn_normal")!, selectedImage: UIImage(named: "MainTabarHomeBtn_selected")!, title: "首页")
        
        let plus = HomePageViewController()
        self.addTabItem(controller: plus, normalImage: UIImage(systemName: "plus")!.withTintColor(ColorTheme, renderingMode: .alwaysOriginal), selectedImage: UIImage(systemName: "plus")!.withTintColor(ColorTheme, renderingMode: .alwaysOriginal), title: "")
        
        let personal = PersonalViewController()
        personal.titles = ["作品", "待审核", "喜欢的"]
        self.addTabItem(controller: personal, normalImage: UIImage(named: "MainTabarMineBtn_normal")!, selectedImage: UIImage(named: "MainTabarMineBtn_selected")!, title: "个人")
    }
    
    func addPlusBtn(image: UIImage, selectedImage: UIImage) {
        self.plusBtn.clipsToBounds = true
        self.plusBtn.layer.cornerRadius = 30
        self.plusBtn.addTarget(self, action: #selector(clickedPlusBtn), for: .touchUpInside)
        self.plusBtn.setImage(image, for: .normal)
        self.plusBtn.setImage(selectedImage, for: .selected)
        self.view.addSubview(self.plusBtn)
        
        self.plusBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.tabBar)
            make.size.equalTo(CGSize(width: 60, height: 60))
            make.bottom.equalTo(self.tabBar.snp.top).offset(40)
        }
    }
    
    func addTabItem(controller: UIViewController, normalImage: UIImage, selectedImage: UIImage, title: String) {
        controller.navigationItem.title = title
        controller.title = title
        controller.tabBarItem.image = normalImage
        controller.tabBarItem.selectedImage = selectedImage
        self.addChild(controller)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
                
        if tabBarController.viewControllers?[1] == viewController {
            return false
        }
                
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if self.selectedIndex == 1 {return}
        
        if self.selectedIndex == 0 {
            self.tabBar.barTintColor = UIColor.clear
            self.tabBar.backgroundImage = UIImage()
        }
        else {
            self.tabBar.barTintColor = UIColor.white            
            self.tabBar.backgroundImage = UIColor.white.drawToImage(size: CGSize(width: 100, height: 50))
        }
    }
    
    @objc func clickedPlusBtn() {
        isLogin = true
        if isLogin {
            let popMenuVC = MainPopMenuViewController()
            popMenuVC.modalPresentationStyle = .fullScreen
            self.navigationController?.present(popMenuVC, animated: true, completion: nil)            
            popMenuVC.selectedAddTypeBlock = {tag in
                switch tag {
                case 0:
                    print("添加音频")
                case 1:
                    print("添加视频")
                default:
                    break
                }
            }
        } else {
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            self.navigationController?.present(loginVC, animated: true, completion: nil)
            loginVC.loginSucessBlock = { [weak self] in
                self!.loginSucess()
            }
        }
    }
    
    func loginSucess() {
        NetWorkManager.cancelAllOperations()
        
        /// 刷新首页
        let homeVC = self.viewControllers?.first as? HomePageViewController
        homeVC?.refreshAction()
        
        /// 刷新个人中心
        
    }
}
