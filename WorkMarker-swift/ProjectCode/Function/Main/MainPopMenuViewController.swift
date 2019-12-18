//
//  MainPopMenuViewController.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/17.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit


typealias selectedAddType = (_ tag: Int) -> Void

class MainPopMenuViewController: UIViewController {
    
    var butonArray = [UIButton]()
    let closeBtn = UIButton(type: .custom)
        
    var selectedAddTypeBlock: selectedAddType?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .white
        
        self.initMenuBtns()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(0.1)), execute: DispatchWorkItem.init(block: {
            self.popMenuBtnAnimation(btnIndex: 0)
        }))
        
        self.closeBtn.setImage(UIImage(named: "透明关闭"), for: .normal)
        self.closeBtn.addTarget(self, action: #selector(clickedCloseBtn), for: .touchUpInside)
        self.view.addSubview(self.closeBtn)
        self.closeBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSize(width: 44, height: 44))
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-44)
        }
    }
    
    func initMenuBtns() {
        let btnInfoArray = [["image": "AudioCourse", "title" : "音频"],
//                            ["image": "ImageTextCourse", "title": "图文"],
                            ["image": "VideoCourse", "title": "视频"]]
        let btnW: CGFloat = 100.0
        let btnY: CGFloat = self.view.bounds.size.height - 230
        let margin: CGFloat = (self.view.bounds.size.width - btnW * CGFloat(btnInfoArray.count)) / CGFloat(btnInfoArray.count + 1)
        
        var btnX = margin
        
        for i in 0..<btnInfoArray.count {
            let info = btnInfoArray[i]
            let btn = UIButton(type: .custom)
            btn.setTitle(info["title"], for: .normal)
            btn.setTitleColor(.darkText, for: .normal)
            btn.setImage(UIImage(named: info["image"]!), for: .normal)
            btn.frame = CGRect(x: btnX, y: btnY, width: btnW, height: btnW)
            btn.transform = CGAffineTransform.init(translationX: 0, y: self.view.bounds.size.height)
            btn.tag = 10000+i
            btn.addTarget(self, action: #selector(clickedMenuBtn(btn:)), for: .touchUpInside)
            self.setupBtnImageAndTitle(spacing: 5, btn: btn)
            self.butonArray.append(btn)
            self.view.addSubview(btn)
            btnX += (margin + btnW)
        }
    }
    
    @objc func clickedMenuBtn(btn: UIButton) {
        if selectedAddTypeBlock != nil {
            self.selectedAddTypeBlock!(btn.tag - 10000)
        }
        self.dismissSelf(animated: false)
    }
    
    func setupBtnImageAndTitle(spacing: CGFloat, btn: UIButton) {
        let imageSize = btn.imageView?.frame.size
        var titleSize = btn.titleLabel?.frame.size
        let string = btn.titleLabel?.text ?? ""
        let textSize = string.boundingRect(with: .zero, options: .usesFontLeading, attributes: [NSAttributedString.Key.font: btn.titleLabel?.font as Any], context: nil)
        let frameSize = CGSize.init(width: CGFloat(ceilf(Float(textSize.width))), height: CGFloat(ceilf(Float(textSize.height))))
        if (titleSize!.width + 0.5 < frameSize.width) {
            titleSize?.width = frameSize.width
        }
        let totalHeight = ((imageSize?.height ?? 0) + (titleSize?.height ?? 0) + spacing)
        btn.imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - (imageSize?.height ?? 0)), left: 0, bottom: 0, right: -(titleSize?.width ?? 0))
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageSize?.width ?? 0), bottom: -(totalHeight - (titleSize?.height ?? 0)), right: 0)
    }
    
    func popMenuBtnAnimation(btnIndex: Int) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            let btn = self.butonArray[btnIndex]
            btn.transform = CGAffineTransform.identity
        }) { (finished) in
            if (btnIndex < (self.butonArray.count - 1)) {
                self.popMenuBtnAnimation(btnIndex: btnIndex + 1)
            }
        }
    }
    
    @objc func clickedCloseBtn() {
        self.dismissSelf(animated: true)
    }
    
    func dismissSelf(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.closeBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat(-Double.pi / 4))
            }
        } else {
            self.closeBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat(-Double.pi / 4))
        }
        self.dismissMenuBtnAnimation(animated: animated)
    }
    
    func dismissMenuBtnAnimation(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                for menuBtn in self.butonArray {
                    menuBtn.transform = CGAffineTransform.init(translationX: 0, y: self.view.bounds.size.height)
                }
            }) { (finished) in
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            for menuBtn in self.butonArray {
                menuBtn.transform = CGAffineTransform.init(translationX: 0, y: self.view.bounds.size.height)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}
