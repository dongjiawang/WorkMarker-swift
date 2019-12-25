//
//  SettingViewController.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/24.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class SettingViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "设置"
        self.noRefresh = true
        self.noLoadMore = true
        
        let quitBtn = UIButton(type: .custom)
        quitBtn.setTitle("退出", for: .normal)
        quitBtn.backgroundColor = ColorTheme
        quitBtn.setTitleColor(.white, for: .normal)
        quitBtn.clipsToBounds = true
        quitBtn.layer.cornerRadius = 4
        quitBtn.addTarget(self, action: #selector(clickedQuiBtn), for: .touchUpInside)
        self.view.addSubview(quitBtn)
        quitBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-50)
            make.width.equalTo(300)
            make.height.equalTo(44)
            make.centerX.equalTo(self.view)
        }
                  
        self.tableView.isScrollEnabled = false
        self.tableView.separatorStyle = .singleLine
        self.tableView.tableFooterView = UIView()
        self.tableView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(quitBtn.snp.top).offset(-50)
        }
    }
    
    @objc func clickedQuiBtn() {
        let alertVC = UIAlertController(title: "提示", message: "确定退出账号?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let confirAction = UIAlertAction(title: "确定", style: .default) { (action) in
         
            UIDevice.current.clearCookie()
            user = nil
            isLogin = false
            let rootVC = self.navigationController?.viewControllers.first as! MainTabBarViewController
            rootVC.resetMainTabVC()            
            self.navigationController?.popToRootViewController(animated: true)
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(confirAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cacheCell = UITableViewCell(style: .value1, reuseIdentifier: "cache")
            cacheCell.textLabel?.text = "清除缓存"
            cacheCell.selectionStyle = .none
            var cacheSize: Double = UIDevice.current.folderSizeAtPath(folderPath: UIDevice.current.getAudioCachePath())
            cacheSize += UIDevice.current.folderSizeAtPath(folderPath: NSTemporaryDirectory())
            
            var resultSize = cacheSize / 1024
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.minimumIntegerDigits = 1
            if resultSize < 1024 {
                numberFormatter.positiveFormat = "####.#KB"
            } else {
                resultSize = resultSize / 1024
                numberFormatter.positiveFormat = "####.#MB"
            }
            let num = NSNumber(value: resultSize)
            cacheCell.detailTextLabel?.text = numberFormatter.string(from: num)
            
            return cacheCell
        }
        let versionCell = UITableViewCell(style: .value1, reuseIdentifier: "version")
        versionCell.textLabel?.text = "关于小书客"
        versionCell.selectionStyle = .none
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        versionCell.detailTextLabel?.text = "V\(String(describing: version))"
        return versionCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            UIDevice.current.clearImageCache()
            UIDevice.current.clearTmpDirectory()
            WMHUD.progressHUD(text: nil, subText: "清除缓存中")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                WMHUD.hideHUD()
                tableView.reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
