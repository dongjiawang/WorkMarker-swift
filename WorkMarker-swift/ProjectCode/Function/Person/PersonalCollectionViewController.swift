//
//  PersonalCollectionViewController.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/17.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit
import JXPagingView

enum PersonalListType {
    case mine
    case likes
    case notAudited
}

let personalCollectionCell = "PersonalCollectionViewCell"

class PersonalCollectionViewController: BaseCollectionViewController {
     
    var listViewDidScrollCallBackBlock: ((UIScrollView) -> Void)?
    var listType = PersonalListType.mine
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.register(PersonalCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: personalCollectionCell)
        
        self.requestCollectionData()
    }
    
    override func requestCollectionData() {
        var url = URLForMineCourse
        if self.listType == .likes {
            url = URLForMineCourseLike
        } else if self.listType == .notAudited {
            url = URLForMineCourseNotAudited
        }
        
        PersonalRequest.reqeustCourseList(url: url, page: self.pageNumber, size: self.pageSize, showHUD: true, success: { (data) in
            let response = data as? PersonalResponse
            let courseList = response?.data
            self.requestCollectionDataSuccess(array: courseList?.content ?? [Course](), dataTotal: courseList?.totalElements ?? 0)
        }) { (error) in
            self.requestNetDataFailed()
        }
    }

    deinit {
        listViewDidScrollCallBackBlock = nil
    }
}

extension PersonalCollectionViewController  {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemW: CGFloat = (collectionView.bounds.size.width - 8) / 4
        return CGSize(width: itemW, height: itemW / 0.75)
    }
        
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: personalCollectionCell, for: indexPath) as? PersonalCollectionViewCell
        
        cell?.setupCourse(course: self.collectionDataArray[indexPath.row] as! Course)
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension PersonalCollectionViewController: JXPagingViewListViewDelegate {
    func listView() -> UIView {
        self.view
    }
    
    func listScrollView() -> UIScrollView {
        self.collectionView
    }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        self.listViewDidScrollCallBackBlock = callback
    }
}
