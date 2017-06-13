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
    var pollVotes = [Set<String>]()
    let queue = SerialOperationQueue()
    var likeDelegate: LikedCellDelegate?
    var post: Posts?
    var totalVotes: Int?
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
        cell.addButton.isHidden = false
        cell.addButton.isEnabled = true
        cell.delegate = self
        cell.tag = indexPath.row
        if (totalVotes != nil){
            cell.backgroundColor = .clear
            cell.inputField.backgroundColor = .clear
            var frameRect = cell.frame;
            //minus one because of database issue where we cant store nil. so there is an off by one due to 
            // me having to store an init value
            if pollVotes[indexPath.row].count - 1 == 0 {
                cell.inputField.textColor = .black
            } else {
                frameRect.size.width =  cell.frame.width * CGFloat(pollVotes[indexPath.row].count - 1)/CGFloat(totalVotes! - pollVotes.count);
                let backgroundView = UIView(frame: frameRect)
                backgroundView.backgroundColor = .lightBlue
                cell.inputField.addSubview(backgroundView)
            }
            //cell.inputField.frame = frameRect;
        }
       // cell.inputField.frame = CGRect(x: cell.inputField.frame.minX, y: cell.inputField.frame.minY, width: cell.frame.width * CGFloat(pollVotes[indexPath.row]!)/CGFloat(totalVotes!), height: cell.frame.height)
      //  cell.inputField.text = pollData[indexPath.row]
        return cell
    }
}

extension PollPostTableViewCell: PollCellDelegate {
    func addNewOption(index: Int) {
        print(index)
        if(pollVotes[index].contains(FacebookIdentityProfile._sharedInstance.userId!)){
            pollVotes[index].remove(at: (pollVotes[index].index(of: FacebookIdentityProfile._sharedInstance.userId!))!)
            totalVotes! -= 1
        } else {
//            for (i, arr) in pollVotes.enumerated() {
//                if (arr.contains(FacebookIdentityProfile._sharedInstance.userId!)){
//                    pollVotes[i].remove(at: (arr.index(of: FacebookIdentityProfile._sharedInstance.userId!))!)
//                    pollVotes[index].insert(FacebookIdentityProfile._sharedInstance.userId!)
//                    //make aws call
//                    updateInDatabase()
//                    tableView.reloadData()
//                    return
//                }
//            }
//        }

            pollVotes[index].insert(FacebookIdentityProfile._sharedInstance.userId!)
            totalVotes! += 1
            //aws call
        }
        updateInDatabase()
        tableView.reloadData()
        let indexPath = IndexPath(row: index, section: 0)
    }
    
    func updateInDatabase(){
        for (i, val) in (pollOptions.enumerated()) {
            post?._postPoll?[val!] = self.pollVotes[i]
        }
        APIClient.sharedInstance.updatePostInfo(post: post!);

    }
}
