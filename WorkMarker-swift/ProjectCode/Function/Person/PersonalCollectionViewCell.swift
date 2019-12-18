//
//  PersonalCollectionViewCell.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/18.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit

class PersonalCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var likeTip: UIImageView!
    var likesLabel: UILabel!
    var lockImage: UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView = UIImageView(frame: self.bounds)
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.contentView.addSubview(self.imageView)
        
        self.likeTip = UIImageView(frame: CGRect(x: 5, y: frame.size.height - 20, width: 15, height: 15))
        self.likeTip.image = UIImage(named: "HomePageLike_normal")
        self.contentView.addSubview(self.likeTip)
        
        self.likesLabel = UILabel(frame: CGRect(x: self.likeTip.frame.origin.x + 20, y: self.likeTip.frame.origin.y - 2.5, width: frame.size.width - 35, height: 20))
        self.likesLabel.textColor = .white
        self.likesLabel.font = UIFont.systemFont(ofSize: 14)
        self.contentView.addSubview(self.likesLabel)
        
        self.lockImage = UIImageView(frame: CGRect(x: frame.size.width - 20, y: frame.size.height - 20, width: 15, height: 15))
        self.lockImage.isHidden = true
        self.lockImage.image = UIImage(named: "icon_not_public")
        self.contentView.addSubview(self.lockImage)
    }
    
    func setupCourse(course: Course) {
        self.imageView.kf.setImage(with: course.imageUrl?.splicingRequestURL(), placeholder: UIImage(named: "courseDefaultListStand"))
        self.likesLabel.text = course.likeCountString
        self.lockImage.isHidden = course.isPublic ?? true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
