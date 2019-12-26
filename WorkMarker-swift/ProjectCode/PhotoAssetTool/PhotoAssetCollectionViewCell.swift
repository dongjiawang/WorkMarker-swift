//
//  PhotoAssetCollectionViewCell.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/26.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class PhotoAssetCollectionViewCell: UICollectionViewCell {
    var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView.frame = self.bounds
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.addSubview(self.imageView)
    }
    
    lazy var unSelectedTip = { () -> UIImageView in
        let tipImage = UIImageView(frame: CGRect(x: self.imageView.frame.size.width - 25, y: 5, width: 20, height: 20))
        tipImage.image = UIImage(named: "btn_circle")
        tipImage.clipsToBounds = true
        tipImage.layer.cornerRadius = 10
        self.addSubview(tipImage)
        return tipImage
    }()
    
    lazy var selectedLabel = { () -> UILabel in
        let label = UILabel(frame: CGRect(x: self.imageView.frame.width, y: 5, width: 20, height: 20))
        label.backgroundColor = .blue
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10)
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.borderWidth = 1
        self.addSubview(label)
        
        return label
    }()
    
    func setupModel(model: PhotoModel) {
        guard let asset = model.photoAsset else {
            
            self.imageView.image = UIImage(named: "drawingImage")
            self.unSelectedTip.isHidden = true
            self.selectedLabel.isHidden = true            
            return
        }
        
        if model.unAble {
            self.unSelectedTip.isHidden = true
            self.selectedLabel.isHidden = false
            self.selectedLabel.backgroundColor = UIColor.init(hex: "#2b2b2b")
        } else if model.isSelected {
            self.selectedLabel.isHidden = false
            self.selectedLabel.backgroundColor = UIColor.init(hex: "#3c85f9")
            self.unSelectedTip.isHidden = true
        }
        else {
            self.selectedLabel.isHidden = true
            self.unSelectedTip.isHidden = false
        }
        
        if (model.thumbnailImage != nil) {
            self.imageView.image = model.thumbnailImage
        } else {
            PhotoAssetTool.shared().fetchThumbnailImage(asset: asset, size: CGSize(width: self.frame.width * 3, height: self.frame.height * 3)) { (image) in
                self.imageView.image = image
                model.thumbnailImage = image
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
