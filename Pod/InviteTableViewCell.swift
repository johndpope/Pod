//
//  InviteTableViewCell.swift
//  Pod
//
//  Created by Max Freundlich on 5/31/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class InviteTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var requestLabel: UILabel!
    @IBOutlet weak var checkBoxImage: UIImageView!
    @IBOutlet weak var xBoxImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePic.layer.cornerRadius = profilePic.frame.height/2
        profilePic.clipsToBounds = true
        requestLabel.font = UIFont.systemFont(ofSize: 20)
        self.backgroundColor = .lightBlue

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
