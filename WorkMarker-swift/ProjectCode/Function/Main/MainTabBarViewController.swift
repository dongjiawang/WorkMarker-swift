//
//  MainTabBarViewController.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/11.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tabBar.tintColor = ColorTheme
        self.tabBar.barTintColor = UIColor.clear
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.shadowImage = UIImage()
        self.delegate = self
        
        self.addChildViewControllers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    func addChildViewControllers() {
        let home = HomePageViewController()
        self.addTabItem(controller: home, normalImage: UIImage(systemName: "house")!.withTintColor(UIColor.lightGray, renderingMode: .alwaysOriginal), selectedImage: UIImage(systemName: "house.fill")!.withTintColor(ColorTheme, renderingMode: .alwaysOriginal), title: "首页")
        
        let plus = HomePageViewController()
        self.addTabItem(controller: plus, normalImage: UIImage(systemName: "plus")!.withTintColor(ColorTheme, renderingMode: .alwaysOriginal), selectedImage: UIImage(systemName: "plus")!.withTintColor(ColorTheme, renderingMode: .alwaysOriginal), title: "")
        
        let personal = HomePageViewController()
        self.addTabItem(controller: personal, normalImage: UIImage(systemName: "person")!.withTintColor(UIColor.lightGray, renderingMode: .alwaysOriginal), selectedImage: UIImage(systemName: "person.fill")!.withTintColor(ColorTheme, renderingMode: .alwaysOriginal), title: "个人")
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
}
