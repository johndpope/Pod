
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        super.awakeFromNib()
        // Initialization code
        profilePic.layer.cornerRadius = profilePic.frame.height/2
        profilePic.clipsToBounds = true
        userName.font = UIFont.systemFont(ofSize: 11)
      //  chatBubble.layer.cornerRadius = 19;
       // chatBubble.layer.backgroundColor = UIColor(red: 220/255, green:220/255, blue: 220/255, alpha: 1.0).cgColor
        commentBody.font = UIFont.systemFont(ofSize: 18)
//        commentBody.sizeToFit()
//        commentBody.backgroundColor = UIColor.clear        
        //chatBubble.sizeToFit()
        let separatorLineView = UIView(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.width + 100, height: 1))
        separatorLineView.backgroundColor = UIColor.gray
        contentView.addSubview(separatorLineView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
