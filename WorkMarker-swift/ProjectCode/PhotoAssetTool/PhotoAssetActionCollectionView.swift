//
//  PhotoAssetActionCollectionView.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/26.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

typealias selectedPhotoChanged = () -> Void
typealias initTemplateImage = () -> Void

let PHOTOASSETACTIONCOLLECTIONVIEWCELL = "PhotoAssetActionCollectionViewCell"

class PhotoAssetActionCollectionView: UIView {
    
    var collectionArray = [PhotoModel]()
    var selectedArray = [PhotoModel]()
    var selectedPhotoChangedBlock: selectedPhotoChanged?
    var initImageBlock: initTemplateImage?
    
        
    var maxSelectedCount = 10

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadCollectionView(photoArray: [PhotoModel]) {
        self.collectionArray = photoArray
        self.photoCollectionView.reloadData()
    }
    
    var allowsMultipleSelection: Bool? {
        didSet {
            self.photoCollectionView.allowsMultipleSelection = allowsMultipleSelection ?? false
        }
    }
        
    lazy var photoCollectionView = { () -> UICollectionView in
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let itemW = (self.bounds.size.width - 50) / 4
        layout.itemSize = CGSize(width: itemW, height: itemW / 0.75)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.allowsSelection = true
        collectionView.register(PhotoAssetCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: PHOTOASSETACTIONCOLLECTIONVIEWCELL)
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        return collectionView
    }()
}

extension PhotoAssetActionCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PHOTOASSETACTIONCOLLECTIONVIEWCELL, for: indexPath) as! PhotoAssetCollectionViewCell
        let cellModel = self.collectionArray[indexPath.row]
        if self.selectedArray.contains(cellModel) {
            cellModel.unAble = true
            let index = self.selectedArray.firstIndex(of: cellModel) ?? 0
            cell.selectedLabel.text = "\(index + 1)"
        }
        cell.setupModel(model: cellModel)
        
        if cellModel.photoAsset == nil && indexPath.row == 0 {
            cell.imageView.contentMode = .center
            
            let label = UILabel(frame: CGRect(x: 0, y: (cell.frame.height - 20) / 2 + 30, width: cell.frame.width, height: 20))
            label.text = "制作模版"
            label.font = UIFont.systemFont(ofSize: 14)
            label.textAlignment = .center
            cell.addSubview(label)
            
        } else {
            cell.imageView.contentMode = .scaleAspectFill
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellModel = self.collectionArray[indexPath.row]
        if cellModel.photoAsset == nil && indexPath.row == 0 {
            if self.initImageBlock != nil {
                self.initImageBlock!()
            }
        } else {
            if self.selectedArray.contains(cellModel) {
                cellModel.isSelected = false
                let index = self.selectedArray.firstIndex(of: cellModel) ?? 0
                self.selectedArray.remove(at: index)
                
            } else {
                cellModel.isSelected = true
                if cellModel.originalImage == nil {
                    PhotoAssetTool.shared().fetchOriginalImage(asset: cellModel.photoAsset!) { (image) in
                        cellModel.originalImage = image
                    }
                    self.selectedArray.append(cellModel)
                }
            }
            if self.selectedPhotoChangedBlock != nil {
                self.selectedPhotoChangedBlock!()
            }
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cellModel = self.collectionArray[indexPath.row]
        cellModel.isSelected = false
        let index = self.selectedArray.firstIndex(of: cellModel) ?? 0
        self.selectedArray.remove(at: index)
        if self.selectedPhotoChangedBlock != nil {
            self.selectedPhotoChangedBlock!()
        }
        collectionView.reloadData()
    }
    
    // 即将选中的时候，如果是单选，就把已选中的状态更改，并清除已选数组，这样就能添加下一个被选中的图片
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView.allowsMultipleSelection {
            if self.selectedArray.count >= self.maxSelectedCount {
                WMHUD.textHUD(text: "最多选取\(self.maxSelectedCount)张图片", delay: 1)
                return false
            }
        } else {
            if self.selectedArray.count > 0 {
                let model = self.selectedArray[0]
                model.isSelected = false
                self.selectedArray.removeAll()                
            }
        }
        return true
    }
    
}
