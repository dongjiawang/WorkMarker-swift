//
//  HomePageViewController.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/11.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class HomePageViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.        
        
        self.perform(#selector(request), with: nil, afterDelay: 3)
    }
    
    @objc func request() {
        NetWorkManager.get(url: URLForHomePageOpen, request: BaseRequest(), showHUD: true, success: { (data) in
            
        }) { (data) in
            
        }
    }

}
