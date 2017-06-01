//
//  CommentsViewController.swift
//  Pod
//
//  Created by Max Freundlich on 5/16/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class CommentHeaderViewController: UIViewController {
    @IBOutlet weak var OPImage: UIImageView!
    @IBOutlet weak var heartImage: UIImageView!
    @IBOutlet weak var OPTitle: UILabel!
    @IBOutlet weak var OPComment: UILabel!
    @IBOutlet weak var numHearts: UILabel!
    @IBOutlet weak var numComments: UILabel!
    @IBOutlet weak var commentFrame: UIView!
    
    let containerView = UIView()
    var messages: [String] = []
    var likedComment: Bool = false
    var postData: Posts?
    override func viewDidLoad() {
        super.viewDidLoad()
        //setOPDetails()
       // setCommentDetails()
       // commentFrame.layer.borderWidth = 1
       // commentFrame.layer.borderColor = UIColor.gray.cgColor
//        let lowerBorder = CALayer()
//        lowerBorder.backgroundColor = UIColor.gray.cgColor
//        lowerBorder.frame = CGRect(x: commentFrame.frame.minX, y: commentFrame.layer.bounds.maxY, width: commentFrame.frame.width, height: 1.0)
//        commentFrame.layer.addSublayer(lowerBorder)
        if(Int((postData?._postType)!) == PostType.photo.hashValue){
            let cell : ThumbnailPostTableViewCell? = Bundle.main.loadNibNamed("ThumbnailPostTableViewCell",owner: nil, options: nil)?.first as! ThumbnailPostTableViewCell
            cell?.frame = CGRect(x: 0, y: 8, width: view.frame.width, height: (cell?.frame.height)!)
            cell?.posterName.text = postData?._posterName
            cell?.posterBody.text = postData?._postContent
            let url = URL(string: (postData?._posterImageURL)!)
            var data = Data()
            do {
                data = try Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                cell?.posterPhoto.image = UIImage(data: data)
            } catch {
                cell?.posterPhoto.image = UIImage(named: "UserIcon")
            }
            cell?.photoContent.image = postData?.image
            cell?.backgroundColor = .white
            containerView.frame = CGRect(x: (cell?.frame.minX)!, y: (cell?.frame.maxY)!, width: view.frame.width, height: view.frame.height - (cell?.frame.height)!)
            view.addSubview(containerView)
            view.addSubview(cell!)

        } else if (Int((postData?._postType)!) == PostType.text.hashValue) {
            let cell : PodPostTableViewCell? = Bundle.main.loadNibNamed("PodPostTableViewCell",owner: nil, options: nil)?.first as! PodPostTableViewCell
            cell?.frame = CGRect(x: 0, y: 8, width: view.frame.width, height: (cell?.frame.height)!)
            cell?.posterName.text = postData?._posterName
            cell?.posterBody.text = postData?._postContent
            cell?.backgroundColor = .white
            containerView.frame = CGRect(x: (cell?.frame.minX)!, y: (cell?.frame.maxY)!, width: view.frame.width, height: view.frame.height - (cell?.frame.height)!)
            view.addSubview(containerView)
            view.addSubview(cell!)

        }
        let controller = storyboard!.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        controller.postData = postData
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
    
    func setOPDetails(){
        //Set Image
        OPImage.image = UIImage(named: "profile-pic")
        OPImage.layer.borderWidth = 1
        OPImage.layer.masksToBounds = false
        OPImage.layer.borderColor = UIColor.black.cgColor
        OPImage.layer.cornerRadius = OPImage.frame.height/2
        OPImage.clipsToBounds = true

        //Set Name
        OPTitle.text = postData?._posterName
        OPTitle.font = UIFont.boldSystemFont(ofSize: 16.0)

        //Set Comment Text
        OPComment.text =  postData?._postContent
    }
    
    func setCommentDetails(){
        numHearts.text =  String(describing: (postData?._numLikes!)!)
        numComments.text = String(describing: (postData?._numComments!)!)
        
        //Set heart to clickable
        heartImage.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action:#selector(heartTapped))
        heartImage.addGestureRecognizer(tapRecognizer)
    }
    
    func heartTapped(){
        if(likedComment){
            heartImage.image = UIImage(named: "heart_gray")
            numHearts.text = String((Int(numHearts.text!)! - 1))
            var numLikes : Int = Int((postData?._numLikes)!)
            numLikes -= 1
            postData?._numLikes = NSNumber(integerLiteral: numLikes)
            APIClient.sharedInstance.updatePostInfo(post: postData!)
        } else {
            heartImage.image = UIImage(named: "heart_red")
            numHearts.text = String((Int(numHearts.text!)! + 1))
            var numLikes : Int = Int((postData?._numLikes)!)
            numLikes += 1
            postData?._numLikes = NSNumber(integerLiteral: numLikes)
            APIClient.sharedInstance.updatePostInfo(post: postData!)
        }
        likedComment = !likedComment
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

}
