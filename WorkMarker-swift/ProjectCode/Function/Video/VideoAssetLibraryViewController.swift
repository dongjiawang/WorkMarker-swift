//
//  VideoAssetLibraryViewController.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/27.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit
import Photos

typealias selectedVideo = (_ model: PhotoModel) -> Void
class VideoAssetLibraryViewController: BaseCollectionViewController {    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.noRefresh = true
        self.noLoadMore = true
        
        PHPhotoLibrary.requestAuthorization { [weak self] (status) in
            if status == .authorized {
                DispatchQueue.main.async {
                    self?.collectionDataArray = PhotoAssetTool.shared().fetchAllVideo()
                    self?.collectionView.register(VideoAssetLibraryCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "VideoAssetLibraryCollectionViewCell")
                    self?.collectionView.reloadData()
                }
            } else {
                self?.settingAuthorization()
            }
        }
    }
    
    func settingAuthorization() {
        let alertVC = UIAlertController(title: "提示", message: "没有相册权限,现在去打开？", preferredStyle: .alert)
        
        let confirAction = UIAlertAction(title: "确定", style: .default) { (action) in
            let url = URL(string: UIApplication.openSettingsURLString)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
        alertVC.addAction(confirAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    override func refreshAction() {
        super.refreshAction()
        self.collectionDataArray = PhotoAssetTool.shared().fetchAllVideo()
        self.collectionView.reloadData()
    }

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemW = (collectionView.bounds.size.width - 50) / 4
        return CGSize(width: itemW, height: itemW / 0.75)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionDataArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoAssetLibraryCollectionViewCell", for: indexPath) as! VideoAssetLibraryCollectionViewCell
        
        let model = self.collectionDataArray[indexPath.row] as! PhotoModel
        cell.updateCellModel(model: model)
        
        return cell
    }
    
    var selectedVideoBlock: selectedVideo?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedVideoBlock != nil {
            selectedVideoBlock!(self.collectionDataArray[indexPath.row] as! PhotoModel)
        }
    }

}
