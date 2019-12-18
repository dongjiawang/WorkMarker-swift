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
        view.editUserIconBlock = {() in
            
        }
        view.editUserNameBlock = { () in
            
        }
        view.settingAppBlock = { () in
            
        }
        view.goBackBlock = { () in
            
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
            collectionVC.collectionView.backgroundColor = .red
        } else if index == 1 {
            collectionVC.collectionView.backgroundColor = .green
        } else {
            collectionVC.collectionView.backgroundColor = .orange
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
