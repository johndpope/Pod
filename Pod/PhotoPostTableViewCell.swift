//
//  PhotoPostTableViewCell.swift
//  Pod
//
//  Created by Max Freundlich on 5/28/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class PhotoPostTableViewCell: UITableViewCell {

    @IBOutlet weak var posterName: UILabel!
    @IBOutlet weak var posterBody: UILabel!
    @IBOutlet weak var posterPhoto: UIImageView!
    @IBOutlet weak var postLikes: UILabel!
    @IBOutlet weak var postComments: UILabel!
    @IBOutlet weak var photoContent: UIImageView!
    let queue = SerialOperationQueue()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        posterPhoto.layer.cornerRadius = posterPhoto.frame.height/2
        posterPhoto.clipsToBounds = true
        posterName.font = UIFont.boldSystemFont(ofSize: 13.0)
        posterBody.font = UIFont.systemFont(ofSize: 13.0)
        postLikes.font  = UIFont.systemFont(ofSize: 12.0)
        postComments.font  = UIFont.systemFont(ofSize: 12.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
