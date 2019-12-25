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

let NotificationUserLikesChange = "NotificationUserLikesChange"


class PersonalViewController: BaseViewController {
    
    var pagingView: JXPagingView!
    var dataSoure: JXSegmentedTitleDataSource = JXSegmentedTitleDataSource()
    var segmentedView: JXSegmentedView!
    var titles = [String]()
    var tableHeaderViewHeight: Int = 200
    var headerInSectionHeight: Int = 50
    var urlArray = [String]()
    
    var isMySelf = true
    
            
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
        pagingView.pinSectionHeaderVerticalOffset = headerInSectionHeight
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
        
        setupSubVCURL()
        // 延迟请求其他列表，因为第一次进来会请求第一个子列表的数据
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.requestSubVCTotal(index: self.urlArray.count - 1)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserLikeListTotal), name: NSNotification.Name(rawValue: NotificationUserLikesChange), object: nil)
    }
    
    func preferredPagingView() -> JXPagingView {
        return JXPagingListRefreshView(delegate: self)
    }
    
    func refreshAction() {
        self.headerView.setupUser(user: user!)
        self.segmentedView.reloadData()
    }
    
    lazy var headerView = { () -> (PersonalHeaderView) in
        let height = UIDevice.current.isiPhoneXMore() ? 180 : 160
        
        let view = PersonalHeaderView(frame: CGRect(x: 0, y: 0, width: Int(self.view.bounds.size.width), height: height))
    
        view.editUserIconBlock = { [weak self] () in
            self?.showImageAlert()
        }
        view.editUserNameBlock = { [weak self] () in
            self?.showEditNameAlert()
        }
        view.settingAppBlock = { [weak self] () in
            let settingVC = SettingViewController()
            self?.navigationController?.pushViewController(settingVC, animated: true)
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

// MARK: - 设置和更新segmentTitles
extension PersonalViewController {
    func setupSubVCURL() {
        if isMySelf {
            self.urlArray = [URLForMineCourse, URLForMineCourseNotAudited, URLForMineCourseLike]
        } else {
            self.urlArray = [URLForMineCourse, URLForMineCourseLike]
        }
    }
    
    func requestSubVCTotal(index: Int) {
        PersonalRequest.reqeustCourseList(url: self.urlArray[index], page: 0, size: 0, showHUD: false, success: { (data) in
            let response = data as? PersonalResponse
            let totalElement = response?.data?.totalElements
            self.dataSoure.titles[index] = "\(self.titles[index])\(String(describing: totalElement))"
            self.segmentedView.reloadDataWithoutListContainer()
            if index > 1 {
                self.requestSubVCTotal(index: index - 1)
            }
        }) { (error) in
            
        }
    }
    
    @objc func updateUserLikeListTotal() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.requestSubVCTotal(index: self.titles.count - 1)
        }
    }
}

// MARK: - 修改用户信息
extension PersonalViewController {
    func showEditNameAlert() {
        let alertVC = UIAlertController(title: "", message: nil, preferredStyle: .alert)
                
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
            WMHUD.textHUD(text: "不能使用空白用户名", delay: 1)
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
        PhotoAssetTool.shared().showImageSheet(controller: self, photos: { (image, finished) in
            self.uploadUserIcon(image: image)
        }) { (image, finished) in
            self.uploadUserIcon(image: image)
        }
    }
    
    func uploadUserIcon(image: UIImage?) {
        guard let newIcon = image else {
            WMHUD.errorHUD(text: nil, subText: "选取头像错误", delay: 1)
            return
        }
        
        PersonalRequest.uploadUserIcon(image: newIcon, userId: "\(String(describing: user?.id))", success: { (data) in
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
