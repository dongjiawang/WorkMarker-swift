//
//  PersonalViewController.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/17.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit
import JXPagingView
import JXSegmentedView
import PKHUD

class PersonalViewController: BaseViewController {
    
    var pagingView: JXPagingView!
    var dataSoure: JXSegmentedTitleDataSource = JXSegmentedTitleDataSource()
    var segmentedView: JXSegmentedView!
    var titles = [String]()
    var tableHeaderViewHeight: Int = 200
    var headerInSectionHeight: Int = 50
            
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        dataSoure.titles = titles
        dataSoure.titleSelectedColor = .white
        dataSoure.titleNormalColor = .darkText
        dataSoure.isTitleColorGradientEnabled = false
        dataSoure.isTitleZoomEnabled = true
        
        segmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: CGFloat(headerInSectionHeight)))
        segmentedView.backgroundColor = .clear
        segmentedView.delegate = self
        segmentedView.isContentScrollViewClickTransitionAnimationEnabled = false
        segmentedView.dataSource = dataSoure
        
        let line = JXSegmentedIndicatorLineView()
        line.indicatorColor = ColorTheme
        line.indicatorWidth = 50
        segmentedView.indicators = [line]
        
        pagingView = preferredPagingView()
        pagingView.mainTableView.gestureDelegate = self
        pagingView.listContainerView.collectionView.gestureDelegate = self
        pagingView.pinSectionHeaderVerticalOffset = 50
        self.view.addSubview(pagingView)
        pagingView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            if (self.parent?.isKind(of: MainTabBarViewController.classForCoder()))! {
                let offset = UIDevice.current.isiPhoneXMore() ? -50 : 0
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(offset)
            } else {
                make.bottom.equalTo(self.view.snp.bottom)
            }
        }
        
        segmentedView.contentScrollView = pagingView.listContainerView.collectionView
    }
    
    func preferredPagingView() -> JXPagingView {
        return JXPagingListRefreshView(delegate: self)
    }
    
    lazy var headerView = { () -> (PersonalHeaderView) in
        let height = UIDevice.current.isiPhoneXMore() ? 180 : 160
        
        let view = PersonalHeaderView(frame: CGRect(x: 0, y: 0, width: Int(self.view.bounds.size.width), height: height))
    
        view.editUserIconBlock = { [weak self] () in
            
        }
        view.editUserNameBlock = { [weak self] () in
            self?.showEditNameAlert()
        }
        view.settingAppBlock = { [weak self] () in
            
        }
        view.goBackBlock = { [weak self] () in
            
        }
        return view
    }()
    
    // MARK: - 渐变背景色
    lazy var headBackgroundView = { () -> (UIView) in
        let view = UIView()
        self.view.layoutIfNeeded()
        view.frame = CGRect(x: 0, y: 0, width: self.pagingView.frame.size.width, height: self.headerView.frame.size.height + 50)
        
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
                
        gradient.colors = [RGBA(r: 254, g: 134, b: 46, a: 1).cgColor, RGBA(r: 255, g: 147, b: 67, a: 1).cgColor]
        
        view.layer.addSublayer(gradient)
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.pagingView.mainTableView.addSubview(self.headBackgroundView)
        self.pagingView.mainTableView.sendSubviewToBack(self.headBackgroundView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.headBackgroundView.removeFromSuperview()
    }
}

// MARK: - 修改用户信息
extension PersonalViewController {
    func showEditNameAlert() {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                
        alertVC.addTextField { (textField) in
            textField.placeholder = "请输入新的名称"
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let confirAction = UIAlertAction(title: "确认", style: .default) { (action) in
            self.updateUserDisplayName(name: alertVC.textFields?.first?.text ?? "")
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(confirAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func updateUserDisplayName(name: String) {
        if name.count == 0 {
            HUD.show(.label("不能使用空白用户名"))
            return
        }
        PersonalRequest.updateUserInfo(name: name, userID: "\(String(describing: user?.id))", success: { (data) in
            user?.displayName = name
            self.headerView.nameLabel.text = name
        }) { (error) in
            
        }
    }
}
// MARK: - 修改头像
extension PersonalViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImageAlert() {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "拍照", style: .default) { (action) in
            
        }
        let libraryAction = UIAlertAction(title: "从相册选取", style: .default) { (action) in
            
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertVC.addAction(cameraAction)
        alertVC.addAction(libraryAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func presentImagePicker(type: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = type
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            HUD.flash(.labeledError(title: "获取图片失败", subtitle: "请重新选择"), delay: 1.5)
            return }
        self.uploadUserIcon(image: image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadUserIcon(image: UIImage) {
        PersonalRequest.uploadUserIcon(image: image, userId: "\(String(describing: user?.id))", success: { (data) in
            let response = data as? [String: Any]
            let imageUrl = response?["avatar"]
            user?.avatar = imageUrl as? String
        }) { (error) in
            
        }
    }
}

// MARK: - JXSegmentedViewDelegate
extension PersonalViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
        self.pagingView.listContainerView.collectionView.scrollToItem(at: NSIndexPath(row: index, section: 0) as IndexPath, at: .centeredHorizontally, animated: false)
    }
}

// MARK: - JXPagingViewDelegate
extension PersonalViewController: JXPagingViewDelegate {
    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        return tableHeaderViewHeight
    }
    
    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        return self.headerView
    }
    
    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        return headerInSectionHeight
    }
    
    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        return segmentedView
    }
    
    func numberOfLists(in pagingView: JXPagingView) -> Int {
        return titles.count
    }
    
    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
        let collectionVC = PersonalCollectionViewController()
        if index == 0 {
            collectionVC.listType = .mine
        } else if index == 1 {
            collectionVC.listType = .likes
        } else {
            collectionVC.listType = .notAudited
        }
        return collectionVC
    }
}

extension PersonalViewController: JXPagingMainTableViewGestureDelegate {
    func mainTableViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //禁止segmentedView左右滑动的时候，上下和左右都可以滚动
        if otherGestureRecognizer == segmentedView?.collectionView.panGestureRecognizer {
            return false
        }
        return gestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder()) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder())
    }
}

extension PersonalViewController: JXPagingListContainerCollectionViewGestureDelegate {
    func pagingListContainerCollectionView(_ collectionView: JXPagingListContainerCollectionView, gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
