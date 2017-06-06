//
//  CommentsViewController.swift
//  Pod
//
//  Created by Max Freundlich on 5/16/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit
import Haneke

class CommentHeaderViewController: UIViewController, CommentCreationDelegate, LikedCellDelegate {
    let containerView = UIView()
    var messages: [String] = []
    var likedComment: Bool = false
    var postData: Posts?
    let photoCell: ThumbnailPostTableViewCell? = nil
    var textCell: PodPostTableViewCell? = nil
    var pollCell: PollPostTableViewCell? = nil
    var commentDelegate: CommentCreationDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        var numLikes = 0
        if postData?._postLikes != nil {
            numLikes = (postData?._postLikes?.count)!
        }
        if(Int((postData?._postType)!) == PostType.photo.hashValue){
            let photoCell =  Bundle.main.loadNibNamed("ThumbnailPostTableViewCell",owner: nil, options: nil)?.first as! ThumbnailPostTableViewCell
            photoCell.frame = CGRect(x: 0, y: 8, width: view.frame.width, height: (photoCell.frame.height)-8)
            photoCell.posterName.text = postData?._posterName
            photoCell.posterBody.text = postData?._postContent
            
            let cache = Shared.dataCache
            if(postData?.userImage == nil){
                cache.fetch(key: (postData?._posterImageURL)!).onSuccess({ (data) in
                    photoCell.posterPhoto.image = UIImage(data: data)
                    self.postData?.userImage = UIImage(data: data)
                }).onFailure({ (err) in
                    let url = URL(string: (self.postData?._posterImageURL)!)
                    var data = Data()
                    do {
                        data = try Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                        photoCell.posterPhoto.image = UIImage(data: data)
                        self.postData?.userImage = UIImage(data: data)
                        
                    } catch {
                        photoCell.posterPhoto.image = UIImage(named: "UserIcon")
                        self.postData?.userImage = UIImage(data: data)
                    }
                })
            } else {
                photoCell.posterPhoto.image = postData?.userImage
            }
            
            
            if(postData?._postLikes != nil){
                if (postData?._postLikes?.contains(FacebookIdentityProfile._sharedInstance.userId!))!{
                    photoCell.heartIcon.imageView?.image = UIImage(named: "heart_red")
                } else {
                    photoCell.heartIcon.imageView?.image = UIImage(named: "heart_gray")
                }
            } else {
                photoCell.heartIcon.imageView?.image = UIImage(named: "heart_gray")
            }
            photoCell.photoContent.image = postData?.image
            photoCell.likeDelegate = self
            photoCell.post = postData
            photoCell.backgroundColor = .white
            photoCell.postLikes.text = String(describing:  (numLikes))
            photoCell.postComments.text = String(describing: (postData?._numComments!)!)
            containerView.frame = CGRect(x: (photoCell.frame.minX), y: (photoCell.frame.maxY), width: view.frame.width, height: view.frame.height - (photoCell.frame.height)-8)
            view.addSubview(containerView)
            view.addSubview(photoCell)

        } else if (Int((postData?._postType)!) == PostType.text.hashValue) {
            let textCell = Bundle.main.loadNibNamed("PodPostTableViewCell",owner: nil, options: nil)?.first as! PodPostTableViewCell
            textCell.frame = CGRect(x: 0, y: 8, width: view.frame.width, height: (textCell.frame.height))
            textCell.posterName.text = postData?._posterName
            textCell.posterBody.text = postData?._postContent
            textCell.postLikes.text = String(describing:  (numLikes))
            textCell.postComments.text = String(describing: (postData?._numComments!)!)
            textCell.likeDelegate = self
            textCell.post = postData
            textCell.backgroundColor = .white
            if(postData?._postLikes != nil){
                if (postData?._postLikes?.contains(FacebookIdentityProfile._sharedInstance.userId!))!{
                    textCell.heartIcon.imageView?.image = UIImage(named: "heart_red")
                } else {
                    textCell.heartIcon.imageView?.image = UIImage(named: "heart_gray")
                }
            } else {
                textCell.heartIcon.imageView?.image = UIImage(named: "heart_gray")
            }
            
            let cache = Shared.dataCache
            if(postData?.userImage == nil){
                cache.fetch(key: (postData?._posterImageURL)!).onSuccess({ (data) in
                    textCell.posterPhoto.image = UIImage(data: data)
                    self.postData?.userImage = UIImage(data: data)
                }).onFailure({ (err) in
                    let url = URL(string: (self.postData?._posterImageURL)!)
                    var data = Data()
                    do {
                        data = try Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                        textCell.posterPhoto.image = UIImage(data: data)
                        self.postData?.userImage = UIImage(data: data)
                        
                    } catch {
                        textCell.posterPhoto.image = UIImage(named: "UserIcon")
                        self.postData?.userImage = UIImage(data: data)
                    }
                })
            } else {
                textCell.posterPhoto.image = postData?.userImage
            }
            
            containerView.frame = CGRect(x: (textCell.frame.minX), y: (textCell.frame.maxY), width: view.frame.width, height: view.frame.height - (textCell.frame.height)-8)
            view.addSubview(containerView)
            view.addSubview(textCell)
            self.textCell = textCell
        } else if (Int((postData?._postType)!) == PostType.poll.hashValue) {
            let pollCell = Bundle.main.loadNibNamed("PollPostTableViewCell",owner: nil, options: nil)?.first as! PollPostTableViewCell
            pollCell.frame = CGRect(x: 0, y: 8, width: view.frame.width, height: (pollCell.frame.height))
            pollCell.username.text = postData?._posterName
            pollCell.postContent.text = postData?._postContent
            pollCell.numLikes.text = String(describing: (numLikes))
            pollCell.likeDelegate = self
            pollCell.post = postData
            pollCell.numComments.text = String(describing: (postData?._numComments!)!)
            pollCell.backgroundColor = .white
            if(postData?._postLikes != nil){
                if (postData?._postLikes?.contains(FacebookIdentityProfile._sharedInstance.userId!))!{
                    pollCell.heartIcon.imageView?.image = UIImage(named: "heart_red")
                } else {
                    pollCell.heartIcon.imageView?.image = UIImage(named: "heart_gray")
                }
            } else {
                pollCell.heartIcon.imageView?.image = UIImage(named: "heart_gray")
            }
            if postData?._postPoll != nil {
                for (key,val) in (postData?._postPoll)! {
                    pollCell.pollOptions.append(key)
                }
                pollCell.tableView.reloadData()
            }
            
            let cache = Shared.dataCache
            if(postData?.userImage == nil){
                cache.fetch(key: (postData?._posterImageURL)!).onSuccess({ (data) in
                    pollCell.profilePic.image = UIImage(data: data)
                    self.postData?.userImage = UIImage(data: data)
                }).onFailure({ (err) in
                    let url = URL(string: (self.postData?._posterImageURL)!)
                    var data = Data()
                    do {
                        data = try Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                        pollCell.profilePic.image = UIImage(data: data)
                        self.postData?.userImage = UIImage(data: data)
                        
                    } catch {
                        pollCell.profilePic.image = UIImage(named: "UserIcon")
                        self.postData?.userImage = UIImage(data: data)
                    }
                })
            } else {
                pollCell.profilePic.image = postData?.userImage
            }
            
            containerView.frame = CGRect(x: (pollCell.frame.minX), y: (pollCell.frame.maxY), width: view.frame.width, height: view.frame.height - (pollCell.frame.height)-8)
            view.addSubview(containerView)
            view.addSubview(pollCell)
            self.pollCell = pollCell
        }
        let controller = storyboard!.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        controller.postData = postData
        controller.commentDelegate = self
        addChildViewController(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view.usingAutolayout())
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        
        controller.didMove(toParentViewController: self)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(CommentHeaderViewController.swiped(_:)))
        self.view.addGestureRecognizer(swipeRight)

    }
    
    func swiped(_ gesture: UIGestureRecognizer){
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func likedCell(post: Posts, type: Int, tag: Int) {
        if(post._postLikes == nil){
            post._postLikes = [FacebookIdentityProfile._sharedInstance.userId!]
            if(Int((postData?._postType)!) == PostType.text.hashValue){
                textCell?.heartIcon.setImage( UIImage(named: "heart_red"), for: .normal)
                textCell?.postLikes.text = "1"
            } else if(Int((postData?._postType)!) == PostType.photo.hashValue){
                photoCell?.heartIcon.setImage( UIImage(named: "heart_red"), for: .normal)
                photoCell?.postLikes.text = "1"
            } else if(Int((postData?._postType)!) == PostType.poll.hashValue){
                pollCell?.heartIcon.setImage( UIImage(named: "heart_red"), for: .normal)
                pollCell?.numLikes.text = "1"
            }
        } else if (post._postLikes?.contains(FacebookIdentityProfile._sharedInstance.userId!))!{
            post._postLikes?.remove(FacebookIdentityProfile._sharedInstance.userId!)
            if(Int((postData?._postType)!) == PostType.text.hashValue){
                textCell?.heartIcon.setImage(UIImage(named: "heart_gray"), for: .normal)
                if post._postLikes != nil {
                    let numLikes = (post._postLikes?.count)!
                    textCell?.postLikes.text = "\(String(describing: numLikes))"
                } else {
                    textCell?.postLikes.text = "0"
                }
            } else if(Int((postData?._postType)!) == PostType.photo.hashValue){
                photoCell?.heartIcon.setImage(UIImage(named: "heart_gray"), for: .normal)
                if post._postLikes != nil {
                    let numLikes = (post._postLikes?.count)!
                    photoCell?.postLikes.text = "\(String(describing: numLikes))"
                } else {
                    photoCell?.postLikes.text = "0"
                }
            } else if(Int((postData?._postType)!) == PostType.poll.hashValue){
                pollCell?.heartIcon.setImage(UIImage(named: "heart_gray"), for: .normal)
                if post._postLikes != nil {
                    let numLikes = (post._postLikes?.count)!
                    pollCell?.numLikes.text = "\(String(describing: numLikes))"
                } else {
                    pollCell?.numLikes.text = "0"
                }
            }
        } else {
            post._postLikes?.insert(FacebookIdentityProfile._sharedInstance.userId!)
            if(Int((postData?._postType)!) == PostType.text.hashValue){
                textCell?.heartIcon.setImage( UIImage(named: "heart_red"), for: .normal)
                if post._postLikes != nil {
                    let numLikes = (post._postLikes?.count)!
                    textCell?.postLikes.text = "\(String(describing: numLikes))"
                } else {
                    textCell?.postLikes.text = "0"
                }
            } else if(Int((postData?._postType)!) == PostType.photo.hashValue){
                photoCell?.heartIcon.setImage( UIImage(named: "heart_red"), for: .normal)
                if post._postLikes != nil {
                    let numLikes = (post._postLikes?.count)!
                    photoCell?.postLikes.text = "\(String(describing: numLikes))"
                } else {
                    photoCell?.postLikes.text = "0"
                }
            } else if(Int((postData?._postType)!) == PostType.poll.hashValue){
                pollCell?.heartIcon.setImage( UIImage(named: "heart_red"), for: .normal)
                if post._postLikes != nil {
                    let numLikes = (post._postLikes?.count)!
                    pollCell?.numLikes.text = "\(String(describing: numLikes))"
                } else {
                    pollCell?.numLikes.text = "0"
                }
            }
        }
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
        self.view.layoutIfNeeded()
        APIClient.sharedInstance.updatePostInfo(post: post)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "containerViewSegue" {
            let containerViewController = segue.destination as? CommentViewController
            containerViewController?.postData = self.postData
        }
    }
    
    func commentCreated(post: Posts){
        self.postData = post
        if(Int((postData?._postType)!) == PostType.photo.hashValue){
            photoCell?.postComments.text = String(describing: (postData?._numComments!))
        } else {
            textCell?.postComments.text = String(describing: (postData?._numComments!)!)
        }
        commentDelegate?.commentCreated(post: post)
    }

}
