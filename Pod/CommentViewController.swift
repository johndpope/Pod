//
//  CommentViewController.swift
//  Pod
//
//  Created by Max Freundlich on 5/22/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import Foundation
import UIKit
import SlackTextViewController

class CommentViewController: SLKTextViewController {
    var messages: [String] = ["This is a message", "Hey, this is a really really long message. I sure hope that all of this text shows up! If not I am really bad at what I do :("]
    override init(tableViewStyle style: UITableViewStyle) {
        super.init(tableViewStyle: .plain)
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override class func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
        return .plain
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView?.register(CommentTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView?.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
       // self.tableView!.register(CommentTableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView?.dataSource = self
        self.tableView?.separatorStyle = UITableViewCellSeparatorStyle.none
        self.isInverted = false
        self.textView.placeholder = "Write message"
        self.textInputbar.backgroundColor = UIColor.lightBlue
        self.shouldScrollToBottomAfterKeyboardShows = true
        self.automaticallyAdjustsScrollViewInsets = false
        
        tableView?.estimatedRowHeight = 60.0 // Replace with your actual estimation
        // Automatic dimensions to tell the table view to use dynamic height
        tableView?.rowHeight = UITableViewAutomaticDimension
       // self.textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView?.allowsSelection = false
        tableView?.setNeedsLayout()
        tableView?.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.tableView!.slk_scrollToBottom(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func didPressRightButton(_ sender: Any?) {
        if(textView.text == "" ){
            return
        }
        messages.append(textView.text)
        tableView?.reloadData()
        self.tableView!.slk_scrollToBottom(animated: true)
        super.didPressRightButton(sender)
    }
    
    override func textViewDidBeginEditing(_ textView: UITextView) {
        super.textViewDidBeginEditing(textView)
        self.tableView!.slk_scrollToBottom(animated: true)
    }
    
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        super.textViewDidEndEditing(textView)

        self.tableView!.slk_scrollToBottom(animated: true)
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        if textView.text != ""{

            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("clicked")
    }
    
    // -----------------------
    // TABLE VIEW DATA METHODS
    // -----------------------
    
    //these four functions are a hacky way of setting the cell spacing
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.messages.count
    }
    
    // There is just one row in every section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 4
    }
    
    // Make the background color show through
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        return 100.0;//Choose your custom row height
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
        cell.transform = (self.tableView?.transform)!
        cell.userName.text = "Max"
        cell.commentBody.text = messages[indexPath.section]
        cell.profilePic.image = UIImage(named: "profile-pic")
//        let chatBubble = UIView(frame: CGRect(x:  cell.commentBody.frame.minX, y: cell.commentBody.frame.minY, width:  cell.commentBody.frame.width, height:  cell.commentBody.frame.height))
//        chatBubble.layer.cornerRadius = 19;
//        chatBubble.backgroundColor = UIColor(red: 220/255, green:220/255, blue: 220/255, alpha: 1.0)
//        cell.addSubview(chatBubble)
        return cell
    }
    

}
