//
//  PodViewController.swift
//  Pod
//
//  Created by Michael-Anthony Doshi on 5/22/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit
import AWSS3
import Haneke

class PodViewController: UIViewController, PostCreationDelegate, CommentCreationDelegate {
    
    // MARK: - Properties
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Sample"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 24.0)
        return titleLabel
    }()
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.borderColor = UIColor.darkGray.cgColor
        tableView.layer.borderWidth = 1.0
        
        return tableView
    }()
    
    private lazy var postButton: UIButton = {
        let postButton = UIButton()
        postButton.setTitle("New Post", for: .normal)
        postButton.setTitleColor(.white, for: .normal)
        postButton.backgroundColor = .lightBlue
        postButton.titleLabel?.textAlignment = .center
        postButton.addTarget(self, action: #selector(toNewPost), for: .touchUpInside)
        return postButton
    }()
    
    private lazy var closeButton: UIButton = {
        let closeButton = UIButton()
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.addTarget(self, action: #selector(closePod), for: .touchUpInside)
        return closeButton
    }()
    
    private lazy var membersButton: UIButton = {
        let membersButton = UIButton()
        membersButton.setImage(UIImage(named: "members-icon"), for: UIControlState.normal)
        membersButton.setTitleColor(.white, for: .normal)
        membersButton.addTarget(self, action: #selector(viewMembers), for: .touchUpInside)
        return membersButton
    }()
    
    lazy var emptyPodView: UIImageView = {
        let dolphinImage = UIImageView()
        dolphinImage.image = UIImage(named: "dolphins_blue_no_posts")
        return dolphinImage
    }()
    
    var postButtonBottomConstraint: NSLayoutConstraint!
    
    let postButtonHeight: CGFloat = 50.0
    let titleTopMargin: CGFloat = 11.0 + UIApplication.shared.statusBarFrame.height
    let titleBottomMargin: CGFloat = 6.0
    var podData: PodList?
    
    // MARK: - PodViewController
    var initialized = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightBlue
        
        view.addSubview(titleLabel.usingAutolayout())
        view.addSubview(tableView.usingAutolayout())
        view.addSubview(postButton.usingAutolayout())
        view.addSubview(closeButton.usingAutolayout())
        view.addSubview(membersButton.usingAutolayout())
        if(podData?.postData?.isEmpty)!{
            view.addSubview(emptyPodView.usingAutolayout())
        }

        let nib = UINib(nibName: "PodPostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PodPostTableViewCell")
        let photoNib = UINib(nibName: "PhotoPostTableViewCell", bundle: nil)
        tableView.register(photoNib, forCellReuseIdentifier: "PhotoPostTableViewCell")
        let pollNib = UINib(nibName: "PollPostTableViewCell", bundle: nil)
        tableView.register(pollNib, forCellReuseIdentifier: "PollPostTableViewCell")
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.estimatedRowHeight = 60.0 // Replace with your actual estimation
        // Automatic dimensions to tell the table view to use dynamic height
        tableView.rowHeight = UITableViewAutomaticDimension
        // self.textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        titleLabel.text = podData?._name
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let newConstraint = postButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        UIView.animate(withDuration: 0.3) {
            self.view.removeConstraint(self.postButtonBottomConstraint)
            self.view.addConstraint(newConstraint)
            
            self.view.layoutIfNeeded()
        }
        postButtonBottomConstraint = newConstraint
    }
    
    // MARK: - Helper Methods
    
    private func setupConstraints() {
        
        // Title Label
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: titleTopMargin),
            ])
        
        // Post Button
        postButtonBottomConstraint = postButton.topAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([
            postButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postButtonBottomConstraint,
            postButton.heightAnchor.constraint(equalToConstant: postButtonHeight)
            ])
        
        // Table View
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: titleBottomMargin),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: postButton.topAnchor)
            ])
        
        // Close Button
        NSLayoutConstraint.activate([
            closeButton.centerYAnchor.constraint(equalTo: membersButton.centerYAnchor),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8.0)
            ])
        
        // Members Button
        NSLayoutConstraint.activate([
            membersButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20.0),
            membersButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0),
            membersButton.heightAnchor.constraint(equalToConstant: 40),
            membersButton.widthAnchor.constraint(equalToConstant: 40)
            ])
        if(podData?.postData?.isEmpty)!{
            //empty pod
            NSLayoutConstraint.activate([
                emptyPodView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
                emptyPodView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50),
                emptyPodView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50),
                emptyPodView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
                ])
        }
    }
    
    func toNewPost() {
        performSegue(withIdentifier: "toNewPost", sender: nil)
    }
    
    func viewMembers() {
        //dismiss(animated: true, completion: nil)
        //self.navigationController?.popViewController(animated: true)
        performSegue(withIdentifier: "toMemberView", sender: nil)
    }
    
    func closePod() {
        //dismiss(animated: true, completion: nil)
        //self.navigationController?.popViewController(animated: true)
        self.performSegue(withIdentifier: "unwindToCarousel", sender: nil)
    }
    
    override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue? {
        if let id = identifier,
            id == "unwindToCarousel" {
            let unwindSegue = PodViewSegueUnwind(identifier: id, source: fromViewController, destination: toViewController, performHandler: { 
                // glah
            })
            return unwindSegue
        }
        
        return super.segueForUnwinding(to: toViewController, from: fromViewController, identifier: identifier)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if(segue.identifier == "toPostComments"){
            if let nextVC = segue.destination as? CommentHeaderViewController {
                nextVC.postData = sender as? Posts
                nextVC.commentDelegate = self
            }
        } else if(segue.identifier == "toNewPost"){
            if let nextVC = segue.destination as? NewPostViewController {
                nextVC.delegate = self
                nextVC.pod = self.podData
            }
        } else if(segue.identifier == "toMemberView"){
            if let nextVC = segue.destination as? PodMembersViewController {
                nextVC.pod = self.podData
            }
        }
    }
    
    func postCreated(post: Posts){
        print("post created")
        self.podData?.postData?.insert(post, at: 0)
        //self.podData?.postData?.append(post)
        if(!((podData?.postData?.isEmpty)!)){
            emptyPodView.removeFromSuperview()
        }
//        let indexPath = NSIndexPath(row: 0, section: 0)
//        self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
        tableView.reloadData()
    }
    
    func commentCreated(post: Posts) {
        for (i, p) in (self.podData?.postData?.enumerated())! {
            if p._podId == post._podId {
                self.podData?.postData?[i]._numComments = post._numComments
                tableView.reloadData()
                return
            }
        }
    }
}

// MARK: - UITableView Methods

extension PodViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(podData?.postData?.count == nil){
            return 0
        }  else if(initialized == false){
            initialized = true
            if(!((podData?.postData?.isEmpty)!)){
                emptyPodView.removeFromSuperview()
            }
            
        }
        return (podData?.postData!.count)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected!")
        let postData = self.podData?.postData?[indexPath.row]
        performSegue(withIdentifier: "toPostComments", sender: postData)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postData = self.podData?.postData?[indexPath.row]
        if podData == nil ||  postData == nil{
            return UITableViewCell()
        }
        if(postData?._postType as! Int == PostType.text.hashValue){
            //handle text
            let cell = tableView.dequeueReusableCell(withIdentifier: "PodPostTableViewCell") as! PodPostTableViewCell
            
            cell.queue.cancelAllOperations()
            
            let operation: BlockOperation = BlockOperation()
            operation.addExecutionBlock {
                DispatchQueue.main.async {
                    if operation.isCancelled {
                        return
                    }
                    cell.posterName.text = postData?._posterName
                    cell.posterBody.text = postData?._postContent
                    cell.postLikes.text = String(describing: (postData?._numLikes!)!)
                    cell.postComments.text = String(describing: (postData?._numComments!)!)
                    
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
                }
            }
            
            
            cell.queue.addOperation(operation)
            
            
            return cell
        } else if(postData?._postType as! Int == PostType.photo.hashValue){
            //handle photos
            let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoPostTableViewCell") as! PhotoPostTableViewCell
            
            
            
            cell.queue.cancelAllOperations()
            
            let operation: BlockOperation = BlockOperation()
            operation.addExecutionBlock {
                DispatchQueue.main.async {
                    if operation.isCancelled {
                        return
                    }
                    cell.posterName.text = postData?._posterName
                    cell.posterBody.text = postData?._postContent
                    cell.postLikes.text = String(describing: (postData?._numLikes!)!)
                    cell.postComments.text = String(describing: (postData?._numComments!)!)
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
                }
            }
            cell.queue.addOperation(operation)
            
            return cell
        } else if(postData?._postType as! Int == PostType.poll.hashValue){
            //handle polls
            let cell = tableView.dequeueReusableCell(withIdentifier: "PollPostTableViewCell") as! PollPostTableViewCell
        
            cell.queue.cancelAllOperations()
            
            let operation: BlockOperation = BlockOperation()
            operation.addExecutionBlock {
                DispatchQueue.main.async {
                    if operation.isCancelled {
                        return
                    }
                    cell.username.text = postData?._posterName
                    cell.postContent.text = postData?._postContent
                    cell.numLikes.text = String(describing: (postData?._numLikes!)!)
                    cell.numComments.text = String(describing: (postData?._numComments!)!)
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
                        for (key,val) in (postData?._postPoll)! {
                            cell.pollOptions.append(key)
                        }
                        cell.tableView.reloadData()
                    }
                }
            }
            cell.queue.addOperation(operation)
            
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
