//
//  BaseCollectionViewController.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/17.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit
import MJRefresh
import SnapKit
import LYEmptyView

class BaseCollectionViewController: BaseViewController {

    /// 没有下拉刷新
    var noRefresh = false
    /// 没有加载更多
    var noLoadMore = false
    /// 数据源
    var collectionDataArray = Array<Any>()
    /// 页码
    var pageNumber: Int = 0
    /// 每页数据个数
    var pageSize: Int = 10
    /// 数据总个数
    var dataTotal: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    lazy var collectionView = { () -> (UICollectionView) in
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.backgroundColor = ColorThemeBackground
        if !self.noRefresh {
            collectionView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
                self.refreshAction()
            })
            collectionView.mj_header?.addObserver(self, forKeyPath: "state", options: .new, context: nil)
        }
        if !self.noLoadMore {
            collectionView.mj_footer = MJRefreshBackFooter.init(refreshingBlock: {
                self.loadMoreAction()
            })
            collectionView.mj_footer?.addObserver(self, forKeyPath: "state", options: .new, context: nil)
        }
        
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        return collectionView
    }()
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if self.collectionView.mj_header?.state == MJRefreshState.pulling {
            self.feedbackGenerator()
        } else if self.collectionView.mj_footer?.state == MJRefreshState.pulling {
            self.feedbackGenerator()
        }
    }
    
    func requestCollectionData() {
    
    }
    
    @objc func refreshAction() {
        self.pageNumber = 0
        self.dataTotal = 0
        self.collectionView.mj_header?.endRefreshing()
        self.collectionView.mj_footer?.endRefreshing()
        self.collectionDataArray.removeAll()
        self.collectionView.reloadData()
        
        self.requestCollectionData()
    }
    
    @objc func loadMoreAction() {
        if self.dataTotal <= self.collectionDataArray.count {
            self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
            return
        }
        self.collectionView.mj_footer?.endRefreshing()
        self.pageNumber += 1
        self.requestCollectionData()
    }
    
    func requestCollectionDataSuccess(array: Array<Any>, dataTotal: Double) {
        self.dataTotal = Int(dataTotal)
        self.collectionDataArray.append(array)
        self.collectionView.reloadData()
        
        if self.collectionDataArray.count == 0 {
            self.collectionView.ly_emptyView = LYEmptyView.emptyActionView(with: UIImage(named: "NoDataTipImage"), titleStr: "无数据", detailStr: "请稍后再试", btnTitleStr: "重新加载", btnClick: {
                self.requestCollectionData()
            })
        }
    }
    
    func requestNetDataFailed() {
        if self.collectionDataArray.count == 0 {
            self.collectionView.ly_emptyView = LYEmptyView.emptyActionView(with: UIImage(named: "NoDataTipImage"), titleStr: "网络请求失败", detailStr: "请稍后再试", btnTitleStr: "重新加载", btnClick: {
                self.requestCollectionData()
            })
        }
    }
    
    func feedbackGenerator() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

extension BaseCollectionViewController: UICollectionViewDelegate {

}

extension BaseCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = UICollectionViewCell()
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionDataArray.count
    }
}

extension BaseCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemW = (collectionView.bounds.size.width - 30) / 2
        return CGSize(width: itemW, height: (itemW * 0.6 + 70))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }
}
