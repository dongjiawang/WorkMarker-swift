//
//  HomePageTableViewCell.swift
//  WorkMarker-swift
//
//  Created by dongjiawang on 2019/12/16.
//  Copyright © 2019 dongjiawang. All rights reserved.
//

import UIKit
import AVKit
import Kingfisher

typealias OnPlayerReady = () -> Void

class HomePageTableViewCell: UITableViewCell {
    
    var playerView: AVPlayerView = AVPlayerView()
    var coverImageView: UIImageView = UIImageView()
    var pauseIcon: UIImageView = UIImageView()
    var userIcon: UIButton = UIButton(type: .custom)
    var likeBtn: UIButton = UIButton(type: .custom)
    var likesCountLabel: UILabel = UILabel()
    var messageBtn: UIButton = UIButton(type: .custom)
    var messageCountLabel: UILabel = UILabel()
    var playerStatusBar: UIView = UIView()
    var titleLabel: UILabel = UILabel()
    var introlLabel: UILabel = UILabel()
    
    var isPlayerReady = false
    var _rate: CGFloat?
    
    var onPlayerReady: OnPlayerReady?
    
    var courseModel: Course?
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        self.contentView.addSubview(self.coverImageView)
        self.coverImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
        
        self.playerView.delegate = self
        self.playerView.backgroundColor = .clear
        self.contentView.addSubview(self.playerView)
        self.playerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
        
        self.pauseIcon.image = UIImage(named: "Homepage_play_pause")
        self.pauseIcon.contentMode = .center
        self.pauseIcon.layer.zPosition = 3
        self.pauseIcon.isHidden = true
        self.contentView.addSubview(self.pauseIcon)
        self.pauseIcon.snp.makeConstraints { (make) in
            make.center.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
        
        self.messageBtn.setImage(UIImage(named: "HomePageMessage"), for: .normal)
        self.messageBtn.addTarget(self, action: #selector(clickedMessageBtn), for: .touchUpInside)
        self.contentView.addSubview(self.messageBtn)
        self.messageBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 44, height: 44))
            make.right.equalTo(-10)
            make.bottom.equalTo(-120)
        }
        
        self.messageCountLabel.textAlignment = .center
        self.messageCountLabel.font = UIFont.systemFont(ofSize: 12)
        self.messageCountLabel.textColor = .white
        self.contentView.addSubview(self.messageCountLabel)
        self.messageCountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.messageBtn.snp.bottom)
            make.height.equalTo(20)
            make.centerX.equalTo(self.messageBtn)
        }
        
        self.likeBtn.setImage(UIImage(named: "HomePageLike_normal"), for: .normal)
        self.likeBtn.setImage(UIImage(named: "HomePageLike_selected"), for: .selected)
        self.likeBtn.addTarget(self, action: #selector(clickedLikeBtn), for: .touchUpInside)
        self.contentView.addSubview(self.likeBtn)
        self.likeBtn.snp.makeConstraints { (make) in
            make.size.right.equalTo(self.messageBtn)
            make.bottom.equalTo(self.messageBtn.snp.top).offset(-20)
        }
        
        self.likesCountLabel.textAlignment = .center
        self.likesCountLabel.font = UIFont.systemFont(ofSize: 12)
        self.likesCountLabel.textColor = .white
        self.contentView.addSubview(self.likesCountLabel)
        self.likesCountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.likeBtn.snp.bottom)
            make.height.equalTo(20)
            make.centerX.equalTo(self.likeBtn)
        }
        
        self.userIcon.setImage(UIImage(named: "userIcon"), for: .normal)
        self.userIcon.clipsToBounds = true
        self.userIcon.layer.cornerRadius = 22
        self.userIcon.addTarget(self, action: #selector(clickedUserIcon), for: .touchUpInside)
        self.contentView.addSubview(self.userIcon)
        self.userIcon.snp.makeConstraints { (make) in
            make.size.right.equalTo(self.messageBtn)
            make.bottom.equalTo(self.likeBtn.snp.top).offset(-20)
        }
        
        self.playerStatusBar.backgroundColor = .white
        self.playerStatusBar.isHidden = true
        self.contentView.addSubview(self.playerStatusBar)
        self.playerStatusBar.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView).offset(-0.5)
            make.width.equalTo(self.contentView)
            make.height.equalTo(0.5)
        }
        
        self.introlLabel.textColor = .white
        self.introlLabel.font = UIFont.systemFont(ofSize: 12)
        self.introlLabel.numberOfLines = 3
        self.contentView.addSubview(self.introlLabel)
        self.introlLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-100)
            make.bottom.equalTo(self.messageCountLabel).offset(-5)
            make.height.greaterThanOrEqualTo(30)
        }
        
        self.titleLabel.textColor = .white
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.introlLabel)
            make.bottom.equalTo(self.introlLabel.snp.top).offset(-5)
            make.height.greaterThanOrEqualTo(20)
        }
    }
    
    func initWithData(data: Course) {
        self.courseModel = data
        
        self.introlLabel.text = data.intro
        self.titleLabel.text = data.user?.displayName
        self.coverImageView.kf.setImage(with: data.imageUrl?.splicingRequestURL())
        self.playerView.setPlayerSourceUrl(url: data.chapter?.startingUrl?.splicingRequestURLString())
        
        let array = data.chapter?.videoRatio?.components(separatedBy: "*")        
        guard let width = Int(array?.first ?? "0"), let height = Int(array?.last ?? "0") else {
            self.playerView.setPlayerVideoGravity(videoGravity: .resizeAspectFill)
            return
        }
        if (width > height) { //error here
            self.playerView.setPlayerVideoGravity(videoGravity: .resizeAspect)
        } else {
            self.playerView.setPlayerVideoGravity(videoGravity: .resizeAspectFill)
        }
        
        self.userIcon.kf.setImage(with: data.user?.avatar?.splicingRequestURL(), for: .normal, placeholder: UIImage(named: "userIcon"))
        self.likeBtn.isSelected = data.isLiked ?? false
        self.likesCountLabel.text = data.likeCountString
        self.messageCountLabel.text = "\(data.commentCount ?? 0)"
        self.pauseIcon.isHidden = true
        self.startLoadingPlayItemAnimation(isStart: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.playerView.cancelLoading()
    }
}

// MARK: - 播放器
extension HomePageTableViewCell {
    func play() {
        self.playerView.play()
    }
    
    func pause() {
        self.playerView.pause()
    }
    
    func replay() {
        self.playerView.replay()
    }
    
    var rate: CGFloat? {
        get {
            return _rate
        }
        set {
            _rate = newValue
        }
    }
}

// MARK: - 按钮点击
extension HomePageTableViewCell {
    @objc func clickedMessageBtn() {
        
    }
    
    @objc func clickedLikeBtn() {
        
    }
    
    @objc func clickedUserIcon() {
        
    }
    
    /// 暂停按钮的动画
    func showPauseViewAnimation(rate: CGFloat) {
        if rate == 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.pauseIcon.alpha = 0
            }) { (finished) in
                self.pauseIcon.isHidden = true
            }
        } else {
            self.pauseIcon.isHidden = false
            self.pauseIcon.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
            self.pauseIcon.alpha = 1
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                self.pauseIcon.transform = CGAffineTransform(scaleX: 1, y: 1)
            }) { (finished) in
            }
        }
    }
    
    /// 加载视频动画
    func startLoadingPlayItemAnimation(isStart: Bool) {
        if isStart {
            self.playerStatusBar.backgroundColor = .white
            self.playerStatusBar.isHidden = false
            self.playerStatusBar.layer.removeAllAnimations()
            
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = 0.8
            animationGroup.beginTime = CACurrentMediaTime() + 0.5
            animationGroup.repeatCount = MAXFLOAT
            animationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            let scaleAnimation = CABasicAnimation()
            scaleAnimation.keyPath = "transform.scale.x"
            scaleAnimation.fromValue = 1.0
            scaleAnimation.toValue = 1.0 * self.bounds.size.width
            
            let alphaAnimation = CABasicAnimation()
            alphaAnimation.keyPath = "opacity"
            alphaAnimation.fromValue = 1.0
            alphaAnimation.toValue = 0.5
            
            animationGroup.animations = [scaleAnimation, alphaAnimation]
            
            self.playerStatusBar.layer.add(animationGroup, forKey: nil)
        } else {
            self.playerStatusBar.layer.removeAllAnimations()
            self.playerStatusBar.isHidden = true
        }
    }
}

extension HomePageTableViewCell: AVPlayerViewDelegate {
    func onProgressUpdate(current: CGFloat, total: CGFloat) {
        
    }
    
    func onPlayItemStatusUpdate(status: AVPlayerItem.Status) {
        switch status {
        case .unknown:
            self.startLoadingPlayItemAnimation(isStart: true)
        case .readyToPlay:
            self.startLoadingPlayItemAnimation(isStart: false)
            self.isPlayerReady = true
            onPlayerReady?()
        case .failed:
            self.startLoadingPlayItemAnimation(isStart: false)
            WMHUD.textHUD(text: "加载失败", delay: 1)
        default:
            break
        }
    }
}
