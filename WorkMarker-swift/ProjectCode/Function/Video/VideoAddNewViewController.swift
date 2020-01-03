//
//  VideoAddNewViewController.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/27.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class VideoAddNewViewController: BaseViewController {

    let shootBtn = UIButton(type: .custom)
    let photoBtn = UIButton(type: .custom)
    
    var selectedModel: PhotoModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "选取视频"
        
        let rightItem = UIBarButtonItem(title: "下一步", style: .plain, target: self, action: #selector(nextAction))
        rightItem.tintColor = .white
        self.navigationItem.rightBarButtonItem = rightItem
        
        initBottomBtn()
        clickedPhotosBtn()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func nextAction() {
        if self.selectedModel == nil {
            WMHUD.textHUD(text: "请选择或者拍摄一个视频", delay: 1)
        } else {
            
        }
    }
    
    func initBottomBtn() {
        var btnH = 44
        if UIDevice.current.isiPhoneXMore() {
            btnH = 64
        }
        
        self.shootBtn.backgroundColor = .white
        self.shootBtn.setTitle("拍摄", for: .normal)
        self.shootBtn.setTitleColor(.darkGray, for: .normal)
        self.shootBtn.setTitleColor(ColorTheme, for: .selected)
        self.shootBtn.addTarget(self, action: #selector(clickedShootBtn), for: .touchUpInside)
        self.view.addSubview(self.shootBtn)
        self.shootBtn.snp.makeConstraints { (make) in
            make.left.bottom.equalTo(0)
            make.height.equalTo(btnH)
            make.right.equalTo(self.view.snp.centerX)
        }
        
        self.photoBtn.backgroundColor = .white
        self.photoBtn.setTitle("手机相册", for: .normal)
        self.photoBtn.setTitleColor(.darkGray, for: .normal)
        self.photoBtn.setTitleColor(ColorTheme, for: .selected)
        self.photoBtn.addTarget(self, action: #selector(clickedPhotosBtn), for: .touchUpInside)
        self.view.addSubview(self.photoBtn)
        self.photoBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self.shootBtn.snp.right)
            make.height.width.bottom.equalTo(self.shootBtn)
        }
    }
    
    @objc func clickedShootBtn() {
        PhotoAssetTool.shared().recoredMovie(controller: self, maxTime: 10) { (videoURL, success) in
            if success {
                
            } else {
                WMHUD.errorHUD(text: nil, subText: "拍摄视频失败，请重试", delay: 1)
            }
        }
    }
    
    @objc func clickedPhotosBtn() {
        if self.photoBtn.isSelected {return}
        
        self.photoBtn.isSelected = true
        self.shootBtn.isSelected = false
        
        self.assetLibraryVC.view.isHidden = false
    }
    
    func shootVideoFinish(videoURL: String) {
        
    }
    
    func fetchAVURLAssetToFile() {
        
    }

    lazy var assetLibraryVC = { () -> VideoAssetLibraryViewController in
       let controller = VideoAssetLibraryViewController()
        self.addChild(controller)
        self.view.addSubview(controller.view)
        controller.selectedVideoBlock = { (model) in
            
        }
        controller.view.snp.makeConstraints { (make) in
            make.width.centerX.equalTo(self.view)
            make.top.equalTo(self.view.snp.top)
            make.bottom.equalTo(self.shootBtn.snp.top)
        }
        return controller
    }()
}

extension VideoAddNewViewController: UIVideoEditorControllerDelegate, UINavigationControllerDelegate {
    
}
