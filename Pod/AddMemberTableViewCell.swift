//
//  AddMemberTableViewCell.swift
//  Pod
//
//  Created by Max Freundlich on 5/30/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class AddMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var checkedImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePicture.layer.cornerRadius = profilePicture.frame.height/2
        profilePicture.clipsToBounds = true
        userName.font = UIFont.systemFont(ofSize: 20)
        userName.textColor = .white
        checkedImage.isHidden = true
        self.backgroundColor = .lightBlue
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
