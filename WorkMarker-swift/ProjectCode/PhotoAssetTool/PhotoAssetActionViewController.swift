//
//  PhotoAssetActionViewController.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/27.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit
import Photos

typealias finishPhotoAction = ([PhotoModel]) -> Void
typealias navigationGoBack = () -> Void

class PhotoAssetActionViewController: BaseViewController {

    var finishPhotoActionBlock: finishPhotoAction?
    var navigationGoBackBlock: navigationGoBack?
    
    var hasPreview = false
    var allowsMultipleSelection = false
    var maxSelectedCount = 10
    var showPhotoArray = [PhotoModel]()
    
    var preview: PhotoAssetActionPreview?
    var dragView: UIImageView?
    var photoCollectionView: PhotoAssetActionCollectionView?
    
    var touchingDragView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized {
                self.initPreview()
                self.updatePhotoCollectionViewDataSource()
            } else {
                self.settingAuthorization()
            }
        }
    }
    
    func settingAuthorization() {
        let alertVC = UIAlertController(title: "提示", message: "没有相册权限,现在去打开？", preferredStyle: .alert)
        
        let confirAction = UIAlertAction(title: "确定", style: .default) { (action) in
            let url = URL(string: UIApplication.openSettingsURLString)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(confirAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
            
    @objc override func back() {
        super.back()
        if navigationGoBackBlock != nil {
            navigationGoBackBlock!()
        }
    }
}

// MARK: - 导航栏
extension PhotoAssetActionViewController {
    func setupNavigationBar() {
        self.title = "所有照片"
        self.navigationController?.navigationBar.isTranslucent = false
        
        let leftItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(back))
        leftItem.tintColor = .white
        self.navigationItem.leftBarButtonItem = leftItem
        
        let rightItem = UIBarButtonItem(title: "下一步", style: .plain, target: self, action: #selector(navigationNext))
        rightItem.tintColor = .white
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.barTintColor = ColorTheme
    }
        
    @objc func navigationNext() {
        if self.photoCollectionView?.selectedArray.count == 0 {
            WMHUD.textHUD(text: "至少选择一张图片", delay: 1)
        } else {
            if finishPhotoActionBlock != nil {
                finishPhotoActionBlock!(self.photoCollectionView!.selectedArray)
            }
        }
        super.back()
    }
}

// MARK: - collectionView
extension PhotoAssetActionViewController {
    func setupPhotoListView() {
        var photoViewY: CGFloat = 0
        if hasPreview {
            self.initPreview()
            photoViewY = self.dragView!.frame.origin.y + self.dragView!.frame.height
        }
        
        self.photoCollectionView = PhotoAssetActionCollectionView.init(frame: CGRect(x: 0, y: photoViewY, width: self.view.frame.width, height: self.view.frame.height - photoViewY))
        self.photoCollectionView?.allowsMultipleSelection = self.allowsMultipleSelection
        self.view.addSubview(self.photoCollectionView!)
        self.photoCollectionView?.selectedPhotoChangedBlock = { [weak self] () in
            self?.changedPreviewImage()
        }
        self.photoCollectionView?.initImageBlock = { [weak self] () in
            self?.initTemplate(animation: true)
        }
    }
    
    func initPreview() {
        self.preview = PhotoAssetActionPreview(frame: .zero)
        self.view.addSubview(self.preview!)
        self.preview!.snp.makeConstraints { (make) in
            make.width.centerX.equalTo(self.view)
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(self.view.snp.height).multipliedBy(0.4)
        }
        self.preview?.beginEditBlock = { () in
            
        }
        self.view.layoutIfNeeded()
        
        self.dragView = UIImageView(frame: CGRect(x: 0, y: self.preview!.frame.height + self.preview!.frame.origin.y, width: self.preview!.frame.width, height: 20))
        self.dragView?.backgroundColor = .lightText
        self.dragView?.contentMode = .scaleAspectFit
        self.dragView?.isUserInteractionEnabled = true
        self.dragView?.image = UIImage(named: "photoCollectionDrag")
        self.view.addSubview(self.dragView!)
    }
    
    func updatePhotoCollectionViewDataSource() {
        if self.showPhotoArray.count > 0 {
            self.photoCollectionView?.selectedArray = self.showPhotoArray
        }
        self.photoCollectionView?.reloadCollectionView(photoArray: PhotoAssetTool.shared().fetchAllPhotos(hasCustomPhoto: self.hasPreview))
    }
    
    func changedPreviewImage() {
        let model = self.photoCollectionView?.selectedArray.last
        if model == nil {
            self.preview?.preImage = nil
            return
        }
        
        if model?.photoAsset == nil {
            self.preview?.preImage = nil
            return
        }
        self.preview?.preImage = model?.thumbnailImage
    }
    
    func initTemplate(animation: Bool) {
        let templateVC = TemplateBuildViewController()
        self.navigationController?.pushViewController(templateVC, animated: animation)
        templateVC.finishInitTemplateBlock = { [weak self] (photoModel) in
            self?.addNewTemplateView(model: photoModel)
        }
    }
    
    func addNewTemplateView(model: PhotoModel) {
        self.showPhotoArray.insert(model, at: 1)
        self.photoCollectionView?.selectedArray.append(model)
        self.photoCollectionView?.reloadCollectionView(photoArray: PhotoAssetTool.shared().fetchAllPhotos(hasCustomPhoto: self.hasPreview))
        self.preview?.preImage = model.originalImage
    }
}

// MARK: - 拖动手势
extension PhotoAssetActionViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.hasPreview == false {return}
        
        let touch = touches.first
        if touch?.view == self.dragView {
            touchingDragView = true
            self.photoCollectionView?.frame = CGRect(x: 0, y: self.dragView!.frame.origin.y + self.dragView!.frame.height, width: self.photoCollectionView!.frame.width, height: self.view.frame.height - (self.navigationController!.navigationBar.frame.origin.y + self.navigationController!.navigationBar.frame.height))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.hasPreview == false {return}
        if touchingDragView {
            let bottom = self.preview!.frame.origin.y + self.preview!.frame.height
            
            let touch = touches.first!
            let moveY = touch.previousLocation(in: self.view).y - touch.location(in: self.view).y
            
            if moveY > bottom {return}
            
            let dragTop = (self.dragView!.frame.origin.y - moveY) > bottom ? bottom : (self.dragView!.frame.origin.y - moveY)
            if dragTop < (self.navigationController!.navigationBar.frame.origin.y + self.navigationController!.navigationBar.frame.height) {return}
            self.dragView?.frame = CGRect(x: 0, y: dragTop, width: self.dragView!.frame.width, height: self.dragView!.frame.height)
            self.photoCollectionView?.frame = CGRect(x: 0, y: dragTop + self.dragView!.frame.height, width: self.photoCollectionView!.frame.width, height: self.photoCollectionView!.frame.height)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.hasPreview == false {return}
        if touchingDragView {
            let touch = touches.first!
            let pointY = touch.previousLocation(in: self.view).y
            
            UIView.animate(withDuration: 0.3) {
                let bottom = self.preview!.frame.origin.y + self.preview!.frame.height
                if pointY > self.preview!.center.y {
                    self.dragView?.frame = CGRect(x: 0, y: bottom, width: self.dragView!.frame.width, height: self.dragView!.frame.height)
                } else {
                    self.dragView?.frame = CGRect(x: 0, y: (self.navigationController!.navigationBar.frame.origin.y + self.navigationController!.navigationBar.frame.height), width: self.dragView!.frame.width, height: self.dragView!.frame.height)
                }
                
                let dragViewBottom = self.dragView!.frame.origin.y + self.dragView!.frame.height
                
                self.photoCollectionView?.frame = CGRect(x: 0, y: dragViewBottom, width: self.photoCollectionView!.frame.width, height: self.view.frame.height - dragViewBottom)
            }
        }
        touchingDragView = false
    }
}
