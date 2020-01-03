//
//  VideoCutViewController.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2020/1/3.
//  Copyright © 2020 dongjiawang. All rights reserved.
//

import UIKit
import AVKit

class VideoCutViewController: UIVideoEditorController {

    var stopFindMovieScrubberView = false
    var stopFindOverlayView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        startRelayoutOverLayView()
        startRelayoutMovieView()
    }
    
    func startRelayoutOverLayView() {
        if stopFindOverlayView {return}
        
        hiddenOverlayView(view: self.view)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: UInt64(0.01))) {
            self.startRelayoutOverLayView()
        }
    }
    
    func startRelayoutMovieView() {
        if stopFindMovieScrubberView {return}
        
        relayoutCollectionView(view: self.view)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: UInt64(0.01))) {
            self.startRelayoutMovieView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = ColorTheme
        self.navigationBar.tintColor = .white
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        changeBottomToolBarColor(view: self.view)
    }
    
    func relayoutCollectionView(view: UIView) {
        if stopFindMovieScrubberView {return}
        
        for subView in view.subviews {
            if subView.isKind(of: NSClassFromString("UIMovieScrubber")!) {
                stopFindMovieScrubberView = true
                subView.superview?.snp.makeConstraints({ (make) in
                    make.bottom.equalTo(-100)
                    make.size.equalTo((subView.superview?.snp.size)!)
                    make.height.equalTo(subView.superview!.snp.height)
                })
                return
            }
            relayoutCollectionView(view: subView)
        }
    }
    
    func hiddenOverlayView(view: UIView) {
        if stopFindOverlayView {return}
        
        for subView in view.subviews {
            if subView.isKind(of: NSClassFromString("PLVideoEditingOverlayView")!) {
                stopFindOverlayView = true
                subView.snp.makeConstraints { (make) in
                    make.top.equalTo(self.navigationBar.snp.bottom).offset(20)
                    make.centerX.equalTo(0)
                    make.size.equalTo(subView.snp.size)
                }
                return
            }
            hiddenOverlayView(view: subView)
        }
    }
    
    func changeBottomToolBarColor(view: UIView) {
        for subView in view.subviews {
            if subView.isKind(of: NSClassFromString("UIToolbar")!) {
                let toolbar = subView as! UIToolbar
                toolbar.barTintColor = ColorTheme
                toolbar.tintColor = .white
            }
            changeBottomToolBarColor(view: subView)
        }
    }

}
