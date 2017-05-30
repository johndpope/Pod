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

class PodView: UIView {
    
    // MARK: - Properties
    
    private lazy var tableView: UITableView = {
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
        joinButton.setTitleColor(.darkerGray, for: .normal)
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
    
    var viewLoaded = false
    var lockedPod = false
    var podData: Pod?
    weak var delegate: PodViewDelegate?
    
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
        addSubview(blurEffectView.usingAutolayout())
        //self.addSubview(self.lockImageView)
        //self.addSubview(self.joinButton)
        //setUpLockedView()

        let nib = UINib(nibName: "PodPostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PodPostTableViewCell")
        let photoNib = UINib(nibName: "PhotoPostTableViewCell", bundle: nil)
        tableView.register(photoNib, forCellReuseIdentifier: "PhotoPostTableViewCell")
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.estimatedRowHeight = 60.0 // Replace with your actual estimation
        // Automatic dimensions to tell the table view to use dynamic height
        tableView.rowHeight = UITableViewAutomaticDimension
        // self.textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.allowsSelection = false
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        setupTableViewContraints()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Helper Methods
    
    private func setupTableViewContraints(){
    // Table View
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupBlurConstraints(){
        // Blur View
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.leftAnchor.constraint(equalTo: leftAnchor),
            blurEffectView.rightAnchor.constraint(equalTo: rightAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    private func setupConstraints() {
        
        
        // Blur View
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.leftAnchor.constraint(equalTo: leftAnchor),
            blurEffectView.rightAnchor.constraint(equalTo: rightAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
//        NSLayoutConstraint.activate([
//            lockImageView.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -46.0),
//            lockImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
//            lockImageView.widthAnchor.constraint(equalToConstant: 67.0),
//            lockImageView.heightAnchor.constraint(equalToConstant: 87.0)
//            ])
//        
//        // Join Button
//        NSLayoutConstraint.activate([
//            joinButton.topAnchor.constraint(equalTo: centerYAnchor, constant: 24.5),
//            joinButton.centerXAnchor.constraint(equalTo: centerXAnchor),
//            joinButton.widthAnchor.constraint(equalToConstant: 191.0),
//            joinButton.heightAnchor.constraint(equalToConstant: 34.0)
//            ])
    }
    
    func toSinglePod() {
        if let delegate = delegate {
            delegate.toSinglePod(podData!)
        }
    }
    var setupSubViews = false
    
    func setUpLockedView(){
        DispatchQueue.global(qos: .userInitiated).async {
            while(self.setupSubViews == false){
                if(self.podData != nil){
                    self.setupSubViews = true
                    // Bounce back to the main thread to update the UI
                    if(self.podData?.isLocked)!{
                        DispatchQueue.main.async {
                            self.addSubview(self.blurEffectView)
                            self.addSubview(self.lockImageView)
                            self.addSubview(self.joinButton)
                            self.setupConstraints()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.addSubview(self.blurEffectView)
                            self.setupBlurConstraints()
                        }
                    }
                }
            }
        }
    }
}

extension PodView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(podData?.postData.count == nil){
            return 0
        }
        return (podData?.postData.count)!
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postData = self.podData?.postData[indexPath.row]
        if podData == nil ||  postData == nil{
            return UITableViewCell()
        }
        
        if(postData?._postType as! Int == PostType.text.hashValue){
            //handle text
            let cell = tableView.dequeueReusableCell(withIdentifier: "PodPostTableViewCell") as! PodPostTableViewCell
            
            cell.posterName.text = postData?._posterName
            cell.posterBody.text = postData?._postContent
            cell.postLikes.text = String(describing: (postData?._numLikes!)!)
            cell.postComments.text = String(describing: (postData?._numComments!)!)
            //        if(APIClient.sharedInstance.profilePicture == nil){
            //            cell.posterPhoto.image = APIClient.sharedInstance.getProfileImage()
            //        } else {
            //            cell.posterPhoto.image = APIClient.sharedInstance.profilePicture
            //        }
            
            let url = URL(string: (postData?._posterImageURL)!)
            var data = Data()
            do {
                data = try Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                cell.posterPhoto.image = UIImage(data: data)
            } catch {
                cell.posterPhoto.image = UIImage(named: "UserIcon")
            }
            
//            let identityManager = AWSIdentityManager.default()
            
//            if let imageURL = identityManager.identityProfile?.imageURL {
//                let imageData = try! Data(contentsOf: imageURL)
//                if let profileImage = UIImage(data: imageData) {
//                    cell.posterPhoto.image = profileImage
//                } else {
//                    cell.posterPhoto.image = UIImage(named: "UserIcon")
//                }
//            }
            return cell
        } else if(postData?._postType as! Int == PostType.photo.hashValue){
            //handle photos
            let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoPostTableViewCell") as! PhotoPostTableViewCell
            
            cell.posterName.text = postData?._posterName
            cell.posterBody.text = postData?._postContent
            cell.postLikes.text = String(describing: (postData?._numLikes!)!)
            cell.postComments.text = String(describing: (postData?._numComments!)!)
            
            let url = URL(string: (postData?._posterImageURL)!)
            var data = Data()
            do {
                data = try Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                cell.posterPhoto.image = UIImage(data: data)
            } catch {
                cell.posterPhoto.image = UIImage(named: "UserIcon")
            }
            
            cell.photoContent.image = UIImage(named: "profile-pic")
            return cell
        } else if(postData?._postType as! Int == PostType.poll.hashValue){
            //handle polls
        }
        return UITableViewCell()
    }
}

protocol PodViewDelegate: class {
    func toSinglePod(_ podView: Pod)
}
