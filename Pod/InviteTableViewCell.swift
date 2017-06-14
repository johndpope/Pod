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
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var checkButton: UIButton!
    weak var cellDelegate: InviteTableViewAcceptDelegate?

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
    
    // connect the button from your cell with this method
    @IBAction func buttonPressed(_ sender: UIButton) {
        cellDelegate?.didPressAccept(sender.tag)
        checkButton.setImage(UIImage(named: "check-box-filled"), for: UIControlState.normal)
        cancelButton.setImage(UIImage(named: "x-box"), for: UIControlState.normal)
    }

    @IBAction func xButtonPressed(_ sender: UIButton) {
        cellDelegate?.didPressCancel(sender.tag)
        checkButton.setImage(UIImage(named: "checked-box"), for: UIControlState.normal)
        cancelButton.setImage(UIImage(named: "x-box-filled"), for: UIControlState.normal)
    }
}

protocol InviteTableViewAcceptDelegate : class {
    func didPressAccept(_ tag: Int)
    func didPressCancel(_ tag: Int)
}
