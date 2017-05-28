//
//  PodViewController.swift
//  Pod
//
//  Created by Michael-Anthony Doshi on 5/22/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class PodViewController: UIViewController, PostCreationDelegate {
    
    // MARK: - Properties
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Sample"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 24.0)
        return titleLabel
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 26.0
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
    
    let postButtonHeight: CGFloat = 50.0
    let titleTopMargin: CGFloat = 11.0 + UIApplication.shared.statusBarFrame.height
    let titleBottomMargin: CGFloat = 6.0
    var podData: PodStruct?
    // MARK: - PodViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .lightBlue
        
        view.addSubview(titleLabel.usingAutolayout())
        view.addSubview(tableView.usingAutolayout())
        view.addSubview(postButton.usingAutolayout())
        view.addSubview(closeButton.usingAutolayout())
        let nib = UINib(nibName: "PodPostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PodPostTableViewCell")
        let photoNib = UINib(nibName: "PhotoPostTableViewCell", bundle: nil)
        tableView.register(photoNib, forCellReuseIdentifier: "PhotoPostTableViewCell")
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.estimatedRowHeight = 60.0 // Replace with your actual estimation
        // Automatic dimensions to tell the table view to use dynamic height
        tableView.rowHeight = UITableViewAutomaticDimension
        // self.textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        titleLabel.text = podData?.title
        setupConstraints()
    }
    
    // MARK: - Helper Methods
    
    private func setupConstraints() {
        
        // Title Label
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: titleTopMargin),
            ])
        
        // Post Button
        NSLayoutConstraint.activate([
            postButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            postButton.heightAnchor.constraint(equalToConstant: postButtonHeight)
            ])
        
        // Table View
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: titleBottomMargin),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        // Close Button
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8.0)
            ])
    }
    
    func toNewPost() {
        performSegue(withIdentifier: "toNewPost", sender: nil)
    }
    
    func closePod() {
        //dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if(segue.identifier == "toPostComments"){
            if let nextVC = segue.destination as? CommentHeaderViewController {
                nextVC.postData = sender as! PostDetails
            }
        } else if(segue.identifier == "toNewPost"){
            if let nextVC = segue.destination as? NewPostViewController {
                nextVC.delegate = self
            }
        }
    }
    
    func postCreated(post: PostDetails){
        print("post created")
        self.podData?.postData.append(post)
        tableView.reloadData()
    }
}

// MARK: - UITableView Methods

extension PodViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(podData?.postData.count == nil){
            return 0
        }
        return (podData?.postData.count)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected!")
        let postData = self.podData?.postData[indexPath.row]
        performSegue(withIdentifier: "toPostComments", sender: postData)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postData = self.podData?.postData[indexPath.row]
        if podData == nil ||  postData == nil{
            return UITableViewCell()
        }
        if(postData?.postType == PostType.text){
            //handle text
            let cell = tableView.dequeueReusableCell(withIdentifier: "PodPostTableViewCell") as! PodPostTableViewCell
            
            cell.posterName.text = postData?.posterName
            cell.posterBody.text = postData?.postText
            cell.postLikes.text = String(describing: (postData?.numHearts!)!)
            cell.postComments.text = String(describing: (postData?.numComments!)!)
            if(APIClient.sharedInstance.profilePicture == nil){
                cell.posterPhoto.image = APIClient.sharedInstance.getProfileImage()
            } else {
                cell.posterPhoto.image = APIClient.sharedInstance.profilePicture
            }
            return cell
        } else if(postData?.postType == PostType.photo){
            //handle photos
            let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoPostTableViewCell") as! PhotoPostTableViewCell
            
            cell.posterName.text = postData?.posterName
            cell.posterBody.text = postData?.postText
            cell.postLikes.text = String(describing: (postData?.numHearts!)!)
            cell.postComments.text = String(describing: (postData?.numComments!)!)
            if(APIClient.sharedInstance.profilePicture == nil){
                cell.posterPhoto.image = APIClient.sharedInstance.getProfileImage()
            } else {
                cell.posterPhoto.image = APIClient.sharedInstance.profilePicture
            }
            cell.photoContent.image = postData?.postPhoto
            return cell
        } else if(postData?.postType == PostType.poll){
            //handle polls
        }
        return UITableViewCell()
    }
    
}
