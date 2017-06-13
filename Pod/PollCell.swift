//
//  PollCell.swift
//  Pod
//
//  Created by Michael-Anthony Doshi on 6/2/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class PollCell: UITableViewCell {
    
    // MARK: - IBOulets
    
    @IBOutlet weak var inputField: TextField!
    @IBOutlet weak var addButton: UIButton!
    
    // MARK: - Properties
    
    let cornerRadius: CGFloat = 5.0
    weak var delegate: PollCellDelegate?
    // MARK: - PollCell

    override func awakeFromNib() {
        super.awakeFromNib()
        inputField.layer.cornerRadius = cornerRadius
        addButton.isHidden = true
        addButton.addTarget(self, action: #selector(addNewOption), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Button Actions
    
    func addNewOption() {
        if let delegate = self.delegate {
            delegate.addNewOption(index: self.tag)
        } else {
            print("Poll cell delegate is not set")
        }
    }
}

protocol PollCellDelegate: class {
    func addNewOption(index: Int)
}
