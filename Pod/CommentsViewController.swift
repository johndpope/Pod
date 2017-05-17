//
//  CommentsViewController.swift
//  Pod
//
//  Created by Max Freundlich on 5/16/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var OPImage: UIImageView!
    @IBOutlet weak var OPTitle: UILabel!
    @IBOutlet weak var OPComment: UITextView!
    @IBOutlet weak var numHearts: UILabel!
    @IBOutlet weak var numComments: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var messages: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setOPDetails()
        setCommentDetails()
        tableView.delegate = self
        tableView.dataSource = self
        messages.append("A message")
        messages.append("another message")
        tableView.reloadData()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setOPDetails(){
        //Set Image
        OPImage.image = UIImage(named: "profile-pic")
        OPImage.layer.borderWidth = 1
        OPImage.layer.masksToBounds = false
        OPImage.layer.borderColor = UIColor.black.cgColor
        OPImage.layer.cornerRadius = OPImage.frame.height/2
        OPImage.clipsToBounds = true
        
        //Set Name
        OPTitle.text = "Max Freundlich"
        OPTitle.font = UIFont.boldSystemFont(ofSize: 16.0)

        //Set Comment Text
        OPComment.text = "Come to the lounge for house meeting!"
    }
    
    func setCommentDetails(){
        numHearts.text = "26"
        numComments.text = "5"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell
        cell?.messageBody.text = messages[indexPath.row]
        cell?.messageBody.sizeToFit()
        return cell!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
