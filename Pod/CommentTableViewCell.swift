
//
//  CommentTableViewCell.swift
//  Pod
//
//  Created by Max Freundlich on 5/22/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var commentBody: UILabel!
    @IBOutlet weak var chatBubble: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        super.awakeFromNib()
        // Initialization code
        profilePic.layer.borderWidth = 1
        profilePic.layer.masksToBounds = false
        profilePic.layer.borderColor = UIColor.black.cgColor
        profilePic.layer.cornerRadius = profilePic.frame.height/2
        profilePic.clipsToBounds = true
        userName.font = UIFont.systemFont(ofSize: 11)
        chatBubble.layer.cornerRadius = 19;
        chatBubble.layer.backgroundColor = UIColor(red: 220/255, green:220/255, blue: 220/255, alpha: 1.0).cgColor
        commentBody.font = UIFont.systemFont(ofSize: 18)
        commentBody.sizeToFit()
        commentBody.backgroundColor = UIColor.clear
        
        chatBubble.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
