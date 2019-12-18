//
//  PersonalCollectionViewController.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/17.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit
import JXPagingView

class PersonalCollectionViewController: BaseCollectionViewController {
     
    var listViewDidScrollCallBackBlock: ((UIScrollView) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        self.collectionView.backgroundColor = .red
    }

    deinit {
        listViewDidScrollCallBackBlock = nil
    }
}

extension PersonalCollectionViewController: JXPagingViewListViewDelegate {
    func listView() -> UIView {
        self.view
    }
    
    func listScrollView() -> UIScrollView {
        self.collectionView
    }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        self.listViewDidScrollCallBackBlock = callback
    }
}
