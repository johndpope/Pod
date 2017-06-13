//
//  PodView.swift
//  Pod
//
//  Created by Michael-Anthony Doshi on 5/16/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit
import AWSFacebookSignIn
import AWSCognitoIdentityProvider
import AWSS3
import Haneke

class PodView: UIView {
    
    // MARK: - Properties
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    lazy var joinButton: UIButton = {
        let joinButton = UIButton()
        joinButton.backgroundColor = .lightBlue
        joinButton.layer.cornerRadius = 7.0
        joinButton.layer.borderColor = UIColor.darkerGray.cgColor
        joinButton.layer.borderWidth = 1.0
        joinButton.setTitle("Request to join", for: .normal)
        joinButton.setTitleColor(.white, for: .normal)
        return joinButton
    }()
    
    lazy var blurEffectView: UIView = {
        if self.lockedPod && !UIAccessibilityIsReduceTransparencyEnabled() {
            let blurEffect = UIBlurEffect(style: .light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            return blurEffectView
        } else {
            let transparentView = UIView()
            let podTapGesture = UITapGestureRecognizer(target: self, action: #selector(toSinglePod))
            transparentView.addGestureRecognizer(podTapGesture)
            return transparentView
        }
    }()
    
    lazy var emptyPodView: UIImageView = {
        let dolphinImage = UIImageView()
        dolphinImage.image = UIImage(named: "dolphins_blue_no_posts")
        return dolphinImage
    }()
    lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Be the first to post!"
        return label
    }()
    private let estimatedRowHeight: CGFloat = 60.0

    var initialized = false
    var lockedPod = false
    var podData: PodList?
    weak var delegate: PodViewDelegate?
    var joinDelegate: JoinPodDelegate?
    lazy var lockImageView: UIImageView = {
        let lockImageView = UIImageView(image: UIImage(named: "lock"))
        return lockImageView
    }()
    
    // MARK: - PodView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 26.0
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 1.0
        layer.masksToBounds = true
        
        addSubview(tableView.usingAutolayout())
        addSubview(emptyPodView.usingAutolayout())
        addSubview(emptyLabel.usingAutolayout())
        emptyPodView.isHidden = true
        emptyLabel.isHidden = true
        let nib = UINib(nibName: "PodPostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PodPostTableViewCell")
        let photoNib = UINib(nibName: "PhotoPostTableViewCell", bundle: nil)
        tableView.register(photoNib, forCellReuseIdentifier: "PhotoPostTableViewCell")
        let pollNib = UINib(nibName: "PollPostTableViewCell", bundle: nil)
        tableView.register(pollNib, forCellReuseIdentifier: "PollPostTableViewCell")
        // Automatic dimensions to tell the table view to use dynamic height
        // self.textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = estimatedRowHeight
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.separatorStyle = .none
        setUpConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(triggerDelegate))
        self.joinButton.addGestureRecognizer(tapGesture)
        
        
    }
    
    func triggerDelegate(){
        joinDelegate?.showJoinPodAlert(podView: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Helper Methods
    
    private func setUpConstraints(){
    // Table View
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            emptyPodView.topAnchor.constraint(equalTo: topAnchor, constant: 100),
            emptyPodView.leftAnchor.constraint(equalTo: leftAnchor, constant: 50),
            emptyPodView.rightAnchor.constraint(equalTo: rightAnchor, constant: -50),
            emptyPodView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100)
            ])
        
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: emptyPodView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: emptyPodView.centerYAnchor)
            ])
    }
    
    func setUpBlurEffect(){
        addSubview(blurEffectView.usingAutolayout())
        // Blur View
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.leftAnchor.constraint(equalTo: leftAnchor),
            blurEffectView.rightAnchor.constraint(equalTo: rightAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    func setUpLockConstraints(){

        
        if(lockedPod){
            addSubview(lockImageView.usingAutolayout())
            addSubview(joinButton.usingAutolayout())
            NSLayoutConstraint.activate([
                lockImageView.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -46.0),
                lockImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                lockImageView.widthAnchor.constraint(equalToConstant: 67.0),
                lockImageView.heightAnchor.constraint(equalToConstant: 87.0)
                ])
            
            // Join Button
            NSLayoutConstraint.activate([
                joinButton.topAnchor.constraint(equalTo: centerYAnchor, constant: 24.5),
                joinButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                joinButton.widthAnchor.constraint(equalToConstant: 191.0),
                joinButton.heightAnchor.constraint(equalToConstant: 34.0)
                ])
        }
    }
    
    
    func toSinglePod() {
        if let delegate = delegate {
            delegate.toSinglePod(podData!)
        }
    }
    
}

extension PodView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(podData?.postData == nil){
            return 0
        } else {
            if(initialized == false){
                firstTimeSetup()
            }
        }
        return (podData?.postData!.count)!
    }
    func firstTimeSetup(){
        self.lockedPod = (podData?._isPrivate)! as! Bool
        initialized = true
        if(!(podData?.postData?.isEmpty)!){
            emptyPodView.removeFromSuperview()
            emptyLabel.removeFromSuperview()
        } else {
            emptyPodView.isHidden = false
            emptyLabel.isHidden = false
        }

        if(self.lockedPod){
            if(podData?._userIdList?.contains(FacebookIdentityProfile._sharedInstance.userId!))!{
                //Don't lock!
                //Do we need to do anything here?
                self.lockedPod = false
                self.setUpBlurEffect()
            } else {
                self.setUpBlurEffect()
                APIClient.sharedInstance.getSentRequests(completion: { (requests) in
                    var requestSent = false
                    for request in requests {
                        if Int((request?._requestType)!) == RequestType.join.hashValue {
                            if request?._podId == self.podData?._podId{
                                requestSent = true
                                break
                            }
                        }
                    }
                    if requestSent {
                        self.joinButton.setTitle("Request Sent!", for: UIControlState.normal)
                        self.joinButton.isEnabled = false
                    }
                })
                self.setUpLockConstraints()
            }
        }
        for (i,post) in (podData?.postData)!.enumerated(){
            if(Int(post._postType!) == PostType.photo.hashValue){
                let cache = Shared.dataCache
                cache.fetch(key: post._postImage!).onFailure({ (err) in
                    self.downloadContent(key: post._postImage, postID: post._postId!, index: i)
                }).onSuccess({ (data) in
                    let img = UIImage(data: data as Data)
                    self.podData?.postData?[i].image = img
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postData = self.podData?.postData?[indexPath.row]
        if postData?._postLikes == nil {
            postData?._postLikes = []
        }
        if podData == nil ||  postData == nil{
            return UITableViewCell()
        }
        
        if(postData?._postType as! Int == PostType.text.hashValue){
            //handle text
            let cell = tableView.dequeueReusableCell(withIdentifier: "PodPostTableViewCell") as! PodPostTableViewCell
        
            cell.posterName.text = postData?._posterName
            cell.posterBody.text = postData?._postContent
            cell.postLikes.text = String(describing:  (postData?._postLikes?.count)!)
            cell.postComments.text = String(describing: (postData?._numComments!)!)
            if(postData?._postLikes != nil){
                if (postData?._postLikes?.contains(FacebookIdentityProfile._sharedInstance.userId!))!{
                    cell.heartIcon.imageView?.image = UIImage(named: "heart_red")
                } else {
                    cell.heartIcon.imageView?.image = UIImage(named: "heart_gray")
                }
            } else {
                cell.heartIcon.imageView?.image = UIImage(named: "heart_gray")
            }
            let cache = Shared.dataCache
            if(postData?.userImage == nil){
                cache.fetch(key: (postData?._posterImageURL)!).onSuccess({ (data) in
                    cell.posterPhoto.image = UIImage(data: data)
                    postData?.userImage = UIImage(data: data)
                }).onFailure({ (err) in
                    let url = URL(string: (postData?._posterImageURL)!)
                    var data = Data()
                    do {
                        data = try Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                        cell.posterPhoto.image = UIImage(data: data)
                        postData?.userImage = UIImage(data: data)
                        
                    } catch {
                        cell.posterPhoto.image = UIImage(named: "UserIcon")
                        postData?.userImage = UIImage(data: data)
                        
                    }
                })
            } else {
                cell.posterPhoto.image = postData?.userImage
            }


            return cell
        } else if(postData?._postType as! Int == PostType.photo.hashValue){
            //handle photos
            let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoPostTableViewCell") as! PhotoPostTableViewCell
    
            cell.posterName.text = postData?._posterName
            cell.posterBody.text = postData?._postContent
            cell.postLikes.text = String(describing:  (postData?._postLikes?.count)!)
            cell.postComments.text = String(describing: (postData?._numComments!)!)
            if(postData?._postLikes != nil){
                if (postData?._postLikes?.contains(FacebookIdentityProfile._sharedInstance.userId!))!{
                    cell.heartIcon.imageView?.image = UIImage(named: "heart_red")
                } else {
                    cell.heartIcon.imageView?.image = UIImage(named: "heart_gray")
                }
            } else {
                cell.heartIcon.imageView?.image = UIImage(named: "heart_gray")
            }
            let cache = Shared.dataCache
            if(postData?.userImage == nil){
                cache.fetch(key: (postData?._posterImageURL)!).onSuccess({ (data) in
                    cell.posterPhoto.image = UIImage(data: data)
                    postData?.userImage = UIImage(data: data)
                }).onFailure({ (err) in
                    let url = URL(string: (postData?._posterImageURL)!)
                    var data = Data()
                    do {
                        data = try Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                        cell.posterPhoto.image = UIImage(data: data)
                        postData?.userImage = UIImage(data: data)
                        
                    } catch {
                        cell.posterPhoto.image = UIImage(named: "UserIcon")
                        postData?.userImage = UIImage(data: data)
                        
                    }
                })
            } else {
                cell.posterPhoto.image = postData?.userImage
            }
            if postData?.image == nil {
                cache.fetch(key: (postData?._postImage)!).onSuccess({ (data) in
                    postData?.image = UIImage(data: data)
                    cell.photoContent.image = postData?.image
                }).onFailure({ (err) in
                    postData?.image = UIImage(named: "placeholder")
                    cell.photoContent.image = postData?.image
                })
            } else {
                cell.photoContent.image = postData?.image
            }

            return cell
        } else if(postData?._postType as! Int == PostType.poll.hashValue){

            //handle polls
            let cell = tableView.dequeueReusableCell(withIdentifier: "PollPostTableViewCell") as! PollPostTableViewCell
            
            cell.username.text = postData?._posterName
            cell.postContent.text = postData?._postContent
            cell.numLikes.text = String(describing:  (postData?._postLikes?.count)!)
            cell.numComments.text = String(describing: (postData?._numComments!)!)
            if(postData?._postLikes != nil){
                if (postData?._postLikes?.contains(FacebookIdentityProfile._sharedInstance.userId!))!{
                    cell.heartIcon.imageView?.image = UIImage(named: "heart_red")
                } else {
                    cell.heartIcon.imageView?.image = UIImage(named: "heart_gray")
                }
            } else {
                cell.heartIcon.imageView?.image = UIImage(named: "heart_gray")
            }
            let cache = Shared.dataCache
            if(postData?.userImage == nil){
                cache.fetch(key: (postData?._posterImageURL)!).onSuccess({ (data) in
                    cell.profilePic.image = UIImage(data: data)
                    postData?.userImage = UIImage(data: data)
                }).onFailure({ (err) in
                    let url = URL(string: (postData?._posterImageURL)!)
                    var data = Data()
                    do {
                        data = try Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                        cell.profilePic.image = UIImage(data: data)
                        postData?.userImage = UIImage(data: data)
                        
                    } catch {
                        cell.profilePic.image = UIImage(named: "UserIcon")
                        postData?.userImage = UIImage(data: data)
                        
                    }
                })
            } else {
                cell.profilePic.image = postData?.userImage
            }
            if postData?._postPoll != nil {
                var frame = cell.frame
                for (key,val) in (postData?._postPoll)! {
                    cell.pollOptions.append(key)
                    cell.pollVotes.append(val)
                    frame.size.height += 48
                }
                cell.frame = frame
                cell.tableView.reloadData()
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    fileprivate func downloadContent(key: String?, postID: String, index: Int) {
        let transferManager = AWSS3TransferManager.default()
        
        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("profile_pic.jpg")
        
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        
        downloadRequest?.bucket = "pod-postphotos"
        downloadRequest?.key =  "\(key!)"
        downloadRequest?.downloadingFileURL = downloadingFileURL
        
        transferManager.download(downloadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error as NSError? {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        break
                    default:
                        print("Error downloading: \(String(describing: downloadRequest?.key)) Error: \(error)")
                    }
                } else {
                    print("Error downloading: \(String(describing: downloadRequest?.key)) Error: \(error)")
                }
                return nil
            }
            print("Download complete for: \(String(describing: downloadRequest?.key))")
            let _ = task.result
            
            if let data = NSData(contentsOf: downloadingFileURL) {
                let cache = Shared.dataCache
                cache.set(value: data as Data, key: "\(key!)")
                let img = UIImage(data: data as Data)
                    self.podData?.postData?[index].image = img
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
            }
            return nil
        })
    }
    
}

protocol PodViewDelegate: class {
    func toSinglePod(_ podView: PodList)
}
