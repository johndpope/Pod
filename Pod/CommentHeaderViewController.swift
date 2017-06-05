//
//  CommentsViewController.swift
//  Pod
//
//  Created by Max Freundlich on 5/16/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class CommentHeaderViewController: UIViewController, CommentCreationDelegate {
    let containerView = UIView()
    var messages: [String] = []
    var likedComment: Bool = false
    var postData: Posts?
    let photoCell: ThumbnailPostTableViewCell? = nil
    var textCell: PodPostTableViewCell? = nil
    var commentDelegate: CommentCreationDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        if(Int((postData?._postType)!) == PostType.photo.hashValue){
            let photoCell =  Bundle.main.loadNibNamed("ThumbnailPostTableViewCell",owner: nil, options: nil)?.first as! ThumbnailPostTableViewCell
            photoCell.frame = CGRect(x: 0, y: 8, width: view.frame.width, height: (photoCell.frame.height)-8)
            photoCell.posterName.text = postData?._posterName
            photoCell.posterBody.text = postData?._postContent
            let url = URL(string: (postData?._posterImageURL)!)
            var data = Data()
            do {
                data = try Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                photoCell.posterPhoto.image = UIImage(data: data)
            } catch {
                photoCell.posterPhoto.image = UIImage(named: "UserIcon")
            }
            photoCell.photoContent.image = postData?.image
            photoCell.backgroundColor = .white
            photoCell.postLikes.text = String(describing: (postData?._numLikes!)!)
            photoCell.postComments.text = String(describing: (postData?._numComments!)!)
            containerView.frame = CGRect(x: (photoCell.frame.minX), y: (photoCell.frame.maxY), width: view.frame.width, height: view.frame.height - (photoCell.frame.height)-8)
            view.addSubview(containerView)
            view.addSubview(photoCell)

        } else if (Int((postData?._postType)!) == PostType.text.hashValue) {
            let textCell = Bundle.main.loadNibNamed("PodPostTableViewCell",owner: nil, options: nil)?.first as! PodPostTableViewCell
            textCell.frame = CGRect(x: 0, y: 8, width: view.frame.width, height: (textCell.frame.height))
            textCell.posterName.text = postData?._posterName
            textCell.posterBody.text = postData?._postContent
            textCell.postLikes.text = String(describing: (postData?._numLikes!)!)
            textCell.postComments.text = String(describing: (postData?._numComments!)!)
            textCell.backgroundColor = .white
            containerView.frame = CGRect(x: (textCell.frame.minX), y: (textCell.frame.maxY), width: view.frame.width, height: view.frame.height - (textCell.frame.height)-8)
            view.addSubview(containerView)
            view.addSubview(textCell)
            self.textCell = textCell
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
    

    
//    func heartTapped(){
//        if(likedComment){
//            heartImage.image = UIImage(named: "heart_gray")
//            numHearts.text = String((Int(numHearts.text!)! - 1))
//            var numLikes : Int = Int((postData?._numLikes)!)
//            numLikes -= 1
//            postData?._numLikes = NSNumber(integerLiteral: numLikes)
//            APIClient.sharedInstance.updatePostInfo(post: postData!)
//        } else {
//            heartImage.image = UIImage(named: "heart_red")
//            numHearts.text = String((Int(numHearts.text!)! + 1))
//            var numLikes : Int = Int((postData?._numLikes)!)
//            numLikes += 1
//            postData?._numLikes = NSNumber(integerLiteral: numLikes)
//            APIClient.sharedInstance.updatePostInfo(post: postData!)
//        }
//        likedComment = !likedComment
//    }

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
