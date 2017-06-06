//
//  PollPostTableViewCell.swift
//  Pod
//
//  Created by Max Freundlich on 6/5/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class PollPostTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postContent: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var numLikes: UILabel!
    @IBOutlet weak var numComments: UILabel!
    
    @IBOutlet weak var heartIcon: UIButton!
    var pollOptions = [String?]()
    let queue = SerialOperationQueue()
    var likeDelegate: LikedCellDelegate?
    var post: Posts?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profilePic.layer.cornerRadius = profilePic.frame.height/2
        profilePic.clipsToBounds = true
        username.font = UIFont.boldSystemFont(ofSize: 13.0)
        postContent.font = UIFont.systemFont(ofSize: 13.0)
        numLikes.font  = UIFont.systemFont(ofSize: 12.0)
        numComments.font  = UIFont.systemFont(ofSize: 12.0)
        tableView.dataSource = self
        tableView.delegate = self
        let nib = UINib(nibName: "PollCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PollCell")
        tableView.reloadData()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likedPost(_ sender: Any) {
        likeDelegate?.likedCell(post: post!, type: Int((post?._postType)!), tag: self.tag)
    }
    
}

extension PollPostTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (pollOptions.count)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PollCell") as! PollCell
        cell.inputField.isEnabled = false
        cell.inputField.text = pollOptions[indexPath.row]
      //  cell.inputField.text = pollData[indexPath.row]
        return cell
    }
}
