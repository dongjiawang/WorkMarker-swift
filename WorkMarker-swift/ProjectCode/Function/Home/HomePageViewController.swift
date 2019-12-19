//
//  HomePageViewController.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/11.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit
import SPPermissions

let HomePageCell = "HomePageTableViewCell"


class HomePageViewController: BaseTableViewController {
    
    var currentIndex = 0
    var isCurrentPlayerPause = false
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.        
        self.view.backgroundColor = .black
        
        self.tableView.backgroundColor = .black
        self.tableView.rowHeight = self.view.bounds.height
        self.tableView.register(HomePageTableViewCell.classForCoder(), forCellReuseIdentifier: HomePageCell)
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.contentInsetAdjustmentBehavior = .never
        
        self.requestTableData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tableView.layer.removeAllAnimations()
        let cells = self.tableView.visibleCells as! [HomePageTableViewCell]
        for cell in cells {
            cell.playerView.cancelLoading()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView.snp.remakeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
    
    override func requestTableData() {
        self.requestCourseList()
    }
    
    @objc func applicationEnterBackground() {
        let cell: HomePageTableViewCell = self.tableView.cellForRow(at: NSIndexPath.init(row: self.currentIndex, section: 0) as IndexPath) as! HomePageTableViewCell
        self.isCurrentPlayerPause = cell.rate == 0 ? true : false
        cell.pause()
    }
    
    @objc func applicationBecomeActive() {
        if self.isCurrentPlayerPause == false {
            let cell: HomePageTableViewCell = self.tableView.cellForRow(at: NSIndexPath.init(row: self.currentIndex, section: 0) as IndexPath) as! HomePageTableViewCell
            cell.play()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentIndex" {
            self.isCurrentPlayerPause = false
            weak var cell = self.tableView.cellForRow(at: NSIndexPath.init(row: self.currentIndex, section: 0) as IndexPath) as? HomePageTableViewCell
            if cell?.isPlayerReady == false {
                cell?.replay()
            } else {
                AVPlayerManager.shared().pauseAll()
                cell?.onPlayerReady = { [weak self] in
                    if let indexPath = self?.tableView.indexPath(for: cell!) {
                        if self?.isCurrentPlayerPause == true && indexPath.row == self?.currentIndex {
                            cell?.play()
                        }
                    }
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

extension HomePageViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomePageCell) as! HomePageTableViewCell
        cell.initWithData(data: self.tableDataArray[indexPath.row] as! Course)
        
        return cell
    }
}

// MARK: - 网络请求
extension HomePageViewController {
    func requestCourseList() {
        HomePageRequest.requestCourseList(page: self.pageNumber, size: self.pageSize, success: { (data) in
            if let response = data as? HomePageCourseListResponse {
                let courseList = response.data
                self.requestTableDataSuccess(array: courseList?.content ?? [Course](), dataTotal: courseList?.totalElements ?? 0)
                
                if self.pageNumber == 0 && self.tableDataArray.count > 0 {
                    if self.isViewLoaded && (self.view!.window != nil) {
                        self.currentIndex = 0
                        let indexPath = NSIndexPath.init(row: 0, section: 0)
                        self.tableView.scrollToRow(at: indexPath as IndexPath, at: .middle, animated: false)
                    }
                }
            }
            /// 网络加载框结束后提示权限
            self.showSPPermissionsAlert()
        }) { (error) in
            self.requestNetDataFailed()
            /// 网络加载框结束后提示权限
            self.showSPPermissionsAlert()
        }
    }
}

// MARK: - UIScrollViewDelegate
extension HomePageViewController {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.tableView.visibleCells.count == 0 {
            return
        }
        
        DispatchQueue.main.async {
            let translatePoint = scrollView.panGestureRecognizer.translation(in: scrollView)
            scrollView.panGestureRecognizer.isEnabled = false
            
            if translatePoint.y < -50 && self.currentIndex < (self.tableDataArray.count - 1) {
                self.currentIndex += 1
            }
            if translatePoint.y > 50 && self.currentIndex > 0 {
                self.currentIndex -= 1
            }
            UIView.animate(withDuration: 0.15, animations: {
                self.tableView.scrollToRow(at: NSIndexPath.init(row: self.currentIndex, section: 0) as IndexPath, at: .top, animated: false)
            }) { (finished) in
                scrollView.panGestureRecognizer.isEnabled = true
            }
        }
    }
}

extension HomePageViewController: SPPermissionsDelegate, SPPermissionsDataSource {
    func configure(_ cell: SPPermissionTableViewCell, for permission: SPPermission) -> SPPermissionTableViewCell {
        switch permission {
        case .camera:
            cell.permissionTitleLabel.text = "相机"
            cell.permissionDescriptionLabel.text = "请允许使用摄像头拍照或录像"
        case .photoLibrary:
            cell.permissionTitleLabel.text = "相册"
            cell.permissionDescriptionLabel.text = "请允许使用相册"
        case .microphone:
            cell.permissionTitleLabel.text = "麦克风"
            cell.permissionDescriptionLabel.text = "请允许使用麦克风录制音频"
        
        default:
            
            break
        }
        cell.button.allowTitle = "允许"
        cell.button.allowedTitle = "已允许"
        return cell
    }
    
    func showSPPermissionsAlert() {
        
        let permissions = [SPPermission.camera, .photoLibrary, .microphone].filter { !$0.isAuthorized }
        
        if !permissions.isEmpty {
            let controller = SPPermissions.dialog(permissions)
            controller.titleText = "权限列表"
            controller.headerText = "小书客在正常使用中需要用到以下系统权限，请允许使用"
            controller.footerText = "小书客"
            controller.delegate = self
            controller.dataSource = self
            controller.present(on: self)
        }
    }
}
