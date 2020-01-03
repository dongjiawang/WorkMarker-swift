//
//  VideoAssetLibraryCollectionViewCell.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/27.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class VideoAssetLibraryCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    let durationLabel = UILabel()
    let selectionTip = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView.frame = self.bounds
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.addSubview(self.imageView)

        self.selectionTip.frame = CGRect(x: 5, y: self.imageView.frame.height - 25, width: 20, height: 20)
        self.selectionTip.image = UIImage(named: "btn_circle")
        self.imageView.addSubview(self.selectionTip)

        self.durationLabel.frame = CGRect(x: 0, y: self.frame.height - 20, width: self.frame.width - 5, height: 20)
        self.durationLabel.textColor = .white
        self.durationLabel.textAlignment = .right
        self.addSubview(self.durationLabel)
    }
    
    override var isSelected: Bool {
        didSet {
            self.selectionTip.image = isSelected ? UIImage(named: "btn_selected") : UIImage(named: "btn_circle")
        }
    }
    
    func updateCellModel(model: PhotoModel) {
        if model.thumbnailImage != nil {
            self.imageView.image = model.thumbnailImage
        } else {
            PhotoAssetTool.shared().fetchThumbnailImage(asset: model.photoAsset!, size: self.bounds.size) { [weak self] (image) in
                self?.imageView.image = image
                model.thumbnailImage = image
            }
        }
        
        self.durationLabel.text = model.videoDuration
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
}
