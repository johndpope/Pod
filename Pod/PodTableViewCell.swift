//
//  PodTableViewCell.swift
//  Pod
//
//  Created by Max Freundlich on 5/5/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class PodTableViewCell: UITableViewCell {

    @IBOutlet weak var podTitle: UILabel!
    @IBOutlet weak var podLastPost: UILabel!
    @IBOutlet weak var peopleInPod: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
