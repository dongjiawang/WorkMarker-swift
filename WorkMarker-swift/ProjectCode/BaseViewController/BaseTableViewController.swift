//
//  BaseTableViewController.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/16.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit
import MJRefresh
import SnapKit

class BaseTableViewController: BaseViewController {
    /// 没有下拉刷新
    var noRefresh = false
    /// 没有加载更多
    var noLoadMore = false
    /// 数据源
    var tableDataArray = Array<Any>()
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
    
    lazy var tableView = { () -> (UITableView) in
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = ColorThemeBackground
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.insetsContentViewsToSafeArea = true
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        if !self.noRefresh {
            tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
                self.refreshAction()
            })
            tableView.mj_header?.addObserver(self, forKeyPath: "state", options: .new, context: nil)
        }
        
        if !self.noLoadMore {
            tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingBlock: {
                self.loadMoreAction()
            })
            tableView.mj_footer?.addObserver(self, forKeyPath: "state", options: .new, context: nil)
        }
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.left.right.bottom.equalToSuperview()
        }
        
        return tableView
    }()
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if self.tableView.mj_header?.state == MJRefreshState.pulling {
            self.feedbackGenerator()
        } else if self.tableView.mj_footer?.state == MJRefreshState.pulling {
            self.feedbackGenerator()
        }
    }
    
    func requestTableData() {
    
    }
    
    @objc func refreshAction() {
        self.pageNumber = 0
        self.dataTotal = 0
        self.tableView.mj_header?.endRefreshing()
        self.tableView.mj_footer?.endRefreshing()
        self.tableDataArray.removeAll()
        self.tableView.reloadData()
        
        self.requestTableData()
    }
    
    @objc func loadMoreAction() {
        if self.dataTotal <= self.tableDataArray.count {
            self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            return
        }
        self.tableView.mj_footer?.endRefreshing()
        self.pageNumber += 1
        self.requestTableData()
    }
    
    func requestTableDataSuccess(array: Array<Any>, dataTotal: Double) {
        self.dataTotal = Int(dataTotal)
        self.tableDataArray.append(array)
        self.tableView.reloadData()
    }
    
    func requestNetDataFailed() {
        
    }
    
    func feedbackGenerator() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

extension BaseTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        self.view.endEditing(true)
        return indexPath
    }
}

extension BaseTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableDataArray.count
    }
}
