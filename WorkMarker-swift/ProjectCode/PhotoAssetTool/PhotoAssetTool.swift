//
//  PhotoAssetTool.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/25.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import AssetsLibrary

/// 相机回调
typealias cameraHandler = (_ image: UIImage?, _ finished: Bool) -> ()
/// 相册回调
typealias photoHandler = (_ image: UIImage?, _ finished: Bool) -> Void
/// 录制视频回调
typealias recordMovieHandler = (_ url: URL?, _ finished: Bool) -> ()

class PhotoAssetTool: NSObject {
    /// 弹出的根控制器
    var sheetController: UIViewController?
    var cameraBlock: cameraHandler?
    var photosBlock: photoHandler?
    var recordBlock: recordMovieHandler?
    
    
    private static let instance = { () -> PhotoAssetTool in
        return PhotoAssetTool.init()
    }()
    
    class func shared() -> PhotoAssetTool {
        return instance
    }
    
    
    /// 获取所有图片
    /// - Parameter hasCustomPhoto: 是否插入自定义图片模型
    func fetchAllPhotos(hasCustomPhoto: Bool) -> [PhotoModel] {
        var array = [PhotoModel]()
        
        let option = PHFetchOptions()
        //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(with: .image, options: option)
        result.enumerateObjects { (asset, index, stop) in
            if asset.mediaType == .image {
                let model = PhotoModel()
                model.photoAsset = asset
                model.localIdentifiter = asset.localIdentifier
                model.unAble = false
                array.append(model)
            }
        }
        
        if hasCustomPhoto == true {
            let model = PhotoModel()
            array.append(model)
        }
        return array
    }
    
    /// 获取所有视频
    func fetchAllVideo() -> [PhotoModel] {
        var array = [PhotoModel]()
        let option = PHFetchOptions()
        //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(with: .video, options: option)
        result.enumerateObjects { (asset, index, stop) in
            if asset.mediaType == .video {
                let model = PhotoModel()
                model.photoAsset = asset
                model.localIdentifiter = asset.localIdentifier
                model.unAble = false
                array.append(model)
            }
        }
        return array
    }
    
    
    typealias fetchURLVideoSucess = (_ model: PhotoModel) -> Void
    /// 获取指定URL的视频
    /// - Parameters:
    ///   - videoURL: 视频地址
    ///   - success: 成功回调
    func fetchVideoModel(videoURL: URL, success: @escaping fetchURLVideoSucess) {
        let option = PHFetchOptions()
        //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(with: .video, options: option)

        let model = PhotoModel()
        result.enumerateObjects { (asset, index, stop) in
            if asset.mediaType == .video {
                model.photoAsset = asset
                model.localIdentifiter = asset.localIdentifier
                model.unAble = false
                stop.pointee = true
            }
        }
        success(model)
    }
    
    typealias fetchVideoItemSucess = (_ item: AVPlayerItem?) -> Void
    /// 获取视频播放的item
    /// - Parameters:
    ///   - asset: 视频资源
    ///   - success: 成功回调
    func fetchVideoItem(asset: PHAsset, success: @escaping fetchVideoItemSucess) {
        let option = PHVideoRequestOptions()
        option.isNetworkAccessAllowed = true
        PHImageManager.default().requestPlayerItem(forVideo: asset, options: option) { (item, info) in
            success(item ?? nil)
        }
    }
    
    typealias fetchVideoDataSuccess = (_ data: Data?) -> Void
    /// 获取视频二进制数据
    /// - Parameters:
    ///   - asset: 视频资源
    ///   - success: 成功回调
    func fetchVideoData(asset: PHAsset, success: @escaping fetchVideoDataSuccess) {
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: option) { (data, dataUTI, orientation, info) in
            let cancel = info?[PHImageCancelledKey] as! Bool
            let error = info?[PHImageErrorKey] as? Error
            if ((error == nil) && !cancel) {
                success(data)
            }
        }
    }
    
    typealias fetchVideoAssetSuccess = (_ asset: AVAsset?) -> Void
    /// 获取视频的avasset
    /// - Parameters:
    ///   - asset: 视频资源
    ///   - success: 成功回调
    func fetchVideoAsset(asset: PHAsset, success: @escaping fetchVideoAssetSuccess) {
        let option = PHVideoRequestOptions()
        option.version = .current
        option.deliveryMode = .automatic
        PHImageManager.default().requestAVAsset(forVideo: asset, options: option) { (avasset, audioMix, info) in
            success(avasset)
        }
    }
    
    typealias fetchOriginlImageSuccess = (_ image: UIImage?) -> Void
    /// 获取原图
    /// - Parameters:
    ///   - asset: 图片资源
    ///   - success: 成功回调
    func fetchOriginalImage(asset: PHAsset, success: @escaping fetchOriginlImageSuccess) {
        let option = PHImageRequestOptions()
        option.resizeMode = .none
        option.isNetworkAccessAllowed = true
        PHCachingImageManager.default().requestImageDataAndOrientation(for: asset, options: option) { (data, dataUTI, orientation, info) in
            let cancel = info?[PHImageCancelledKey] as! Bool
            let error = info?[PHImageErrorKey] as? Error
            if error == nil && !cancel {
                if data != nil {
                    success(UIImage(data: data!))
                }
            }
        }
    }
    
    
    typealias fetchThumbnailImageSuccess = (_ image: UIImage?) -> Void
    /// 获取缩略图
    /// - Parameters:
    ///   - asset: 图像资源
    ///   - size: 获取大小
    ///   - success: 成功回调
    func fetchThumbnailImage(asset: PHAsset, size: CGSize, success: @escaping fetchThumbnailImageSuccess) {
        let option = PHImageRequestOptions()
        option.resizeMode = .none
        option.isNetworkAccessAllowed = true
        PHCachingImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: option) { (image, info) in
            let error = info?[PHImageErrorKey] as? Error
            if error == nil {
                success(image)
            }
        }
    }
    
    /// 获取沙盒图片
    /// - Parameter path: 沙盒路径
    func fetchSandboxImage(path: String) -> UIImage? {
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        return UIImage(data: data) ?? nil
        
    }
}

// MARK: - 拍照和选择照片功能
extension PhotoAssetTool: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    /// 判断是否打开相机权限
    func judgeIsHasCameraAuthority() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .restricted || status == .denied {
            return false
        }
        return true
    }
    
    
    /// 弹出选择图片方式的弹窗
    /// - Parameters:
    ///   - controller: 弹出的控制器
    ///   - photos: 相册回调
    ///   - camera: 相机回调
    func showImageSheet(controller: UIViewController, photos: @escaping photoHandler, camera: @escaping cameraHandler) {
        self.sheetController = controller
        self.photosBlock = photos
        self.cameraBlock = camera
        self.showSheetAlert()
    }
    
    func showSheetAlert() {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let cameraAction = UIAlertAction(title: "拍照", style: .default) { (action) in
            self.showCameraAction()
        }
        let photosAction = UIAlertAction(title: "从相册选取", style: .default) { (action) in
            self.showPhotoLibraryAction()
        }
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(cameraAction)
        alertVC.addAction(photosAction)
        self.sheetController?.present(alertVC, animated: true, completion: nil)
    }
    /// 使用相机拍照
    func showCameraAction() {
        if self.judgeIsHasCameraAuthority() {
            if self.cameraBlock != nil {
                self.cameraBlock!(nil, false)
            }
        } else {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.videoQuality = .typeHigh
                picker.sourceType = .camera
                self.sheetController?.present(picker, animated: true, completion: nil)
            }
        }
    }
    /// 显示图片浏览器
    func showPhotoLibraryAction() {
        if self.photosBlock != nil {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = .photoLibrary
            self.sheetController?.present(picker, animated: true, completion: nil)
        }
    }
    
    /// 开始录制视频
    /// - Parameters:
    ///   - controller: 弹出的控制器
    ///   - maxTime: 最大录制时间
    ///   - recordCompeletion: 录制回调
    func recoredMovie(controller: UIViewController, maxTime: TimeInterval, recordCompeletion: @escaping recordMovieHandler) {
        self.recordBlock = recordCompeletion
        let picker = UIImagePickerController()
        picker.videoQuality = .typeHigh
        picker.sourceType = .camera
        picker.cameraDevice = .rear
        picker.mediaTypes = [(kUTTypeMovie as String)]
        if maxTime > 0 {
            picker.videoMaximumDuration = maxTime
        }
        picker.delegate = self
        picker.allowsEditing = true
        controller.present(picker, animated: true, completion: nil)
    }
    
    // MARK: - picker回调
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if picker.sourceType == .camera {
                if self.recordBlock != nil {
                    let url = info[.mediaURL] as! URL
                    self.recordBlock!(url, true)
                } else if self.cameraBlock != nil {
                    let image = info[.originalImage] as! UIImage
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.didFinishSaving(image:error:)), nil)
                }
            } else {
                if self.photosBlock != nil {
                    let image = info[.originalImage] as! UIImage
                    self.photosBlock!(image, true)
                }
            }
        }
    }
    
    /// 保存图片到相册
    /// - Parameters:
    ///   - image: 图片
    ///   - error: 错误结果
    @objc func didFinishSaving(image: UIImage, error: Error?) {
        guard let block = self.cameraBlock else {
            return
        }
        if error != nil {
            block(nil, false)
        } else {
            block(image, true)
        }
    }
        
}
