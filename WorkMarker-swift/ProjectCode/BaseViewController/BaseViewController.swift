//
//  BaseViewController.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/11.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = ColorThemeBackground
        
        initNavigationBarTransparent()
    }    

    func initNavigationBarTransparent() {
        setNavigationBarTitleColor(color: UIColor.white)
        setNavigationBarTintColor(color: UIColor.white)
        setNavigationBarBarTintColor(color: ColorTheme)
        initLeftBarButton()
        setBackgroundColor(color: ColorThemeBackground)
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    func initLeftBarButton() {
        let leftItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    func setBackgroundColor(color: UIColor) {
        self.view.backgroundColor = color
    }
    
    func setNavigationBarTitleColor(color: UIColor) {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]
    }
    
    func setNavigationBarBarTintColor(color: UIColor) {
        self.navigationController?.navigationBar.barTintColor = color
    }
    
    func setNavigationBarTintColor(color: UIColor) {
        self.navigationController?.navigationBar.tintColor = color
    }
    
    func setNavigationBarBackgroundColor(color: UIColor) {
        self.navigationController?.navigationBar.backgroundColor = color
    }
    
    func setNavigationBarBaclgroundImage(image: UIImage) {
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
    }

    func setNavigationBarShadowImage(image: UIImage) {
        self.navigationController?.navigationBar.shadowImage = image
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
        if (self.navigationController != nil && (self.navigationController?.children.count)! > 1)  {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self .dismiss(animated: true, completion: nil)
        }
    }
    
    func navigationBarHeight() -> CGFloat {
        return self.navigationController?.navigationBar.frame.size.height ?? 0
    }
    
    func setLeftButton(imageName: String) {
        let leftItem = UIBarButtonItem(image: UIImage(named: imageName), style: .plain, target: self, action: #selector(back))
        leftItem.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftItem
    }

}
