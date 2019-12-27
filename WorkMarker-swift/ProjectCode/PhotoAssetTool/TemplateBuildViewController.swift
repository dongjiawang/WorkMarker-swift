//
//  TemplateBuildViewController.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/27.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class TemplateBuildViewController: BaseViewController {
    
    let templateBuildView = TemplateBuildView()
    var templateColorCollectionView: UICollectionView?
        
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "选择讲稿模板"
        
        let leftItem = UIBarButtonItem(title: "上一步", style: .plain, target: self, action: #selector(back))
        leftItem.tintColor = .white
        self.navigationItem.leftBarButtonItem = leftItem
        
        let rightItem = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(navigationRightItemClicked))
        rightItem.tintColor = .white
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.templateBuildView.contentImageView.image = UIImage(named: "1")
        self.view.addSubview(self.templateBuildView)
        self.templateBuildView.snp.makeConstraints { (make) in
            make.width.centerX.equalTo(self.view)
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(self.view.snp.height).multipliedBy(0.5).offset(-32)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 44, height: 44)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
        layout.scrollDirection = .horizontal
        self.templateColorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.templateColorCollectionView?.backgroundColor = .clear
        self.templateColorCollectionView?.delegate = self
        self.templateColorCollectionView?.dataSource = self
        self.templateColorCollectionView?.register(TemplateCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "TemplateCollectionViewCell")
        self.view.addSubview(self.templateColorCollectionView!)
        self.templateColorCollectionView!.snp.makeConstraints { (make) in
            make.width.centerX.equalTo(self.view)
            make.top.equalTo(self.templateBuildView.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.templateBuildView.textView.becomeFirstResponder()
    }
    
    typealias finishInitTemplate = (_ photoModel: PhotoModel) -> Void
    var finishInitTemplateBlock: finishInitTemplate?
    
    @objc func navigationRightItemClicked() {
        self.templateBuildView.finishedTemplateBuild { [weak self] (model) in
            if self!.finishInitTemplateBlock != nil {
                self!.finishInitTemplateBlock!(model)
            }
        }
    }
}

extension TemplateBuildViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TemplateCollectionViewCell", for: indexPath) as! TemplateCollectionViewCell
        cell.imageView.image = UIImage(named: "\(indexPath.row + 1)")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TemplateCollectionViewCell
        self.templateBuildView.contentImageView.image = cell.imageView.image
        self.templateBuildView.endEditing(true)
    }
}

// MARK: - CollectionViewCell
class TemplateCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.imageView.frame = self.bounds
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
