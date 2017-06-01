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

    var postData: Posts?
    var comments: [Comments?] = []

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
        
        tableView?.estimatedRowHeight = 20.0 // Replace with your actual estimation
        // Automatic dimensions to tell the table view to use dynamic height
        tableView?.rowHeight = UITableViewAutomaticDimension
       // self.textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView?.allowsSelection = false
        tableView?.setNeedsLayout()
        tableView?.layoutIfNeeded()
        
        APIClient.sharedInstance.getCommentsForPost(withId: (postData?._postId)!) { (comment_arr) in
            self.comments = comment_arr
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
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

        APIClient.sharedInstance.createCommentForPost(withID: (postData?._postId)!, commentBody: textView.text) { (com) in
            self.comments.append(com)
            DispatchQueue.main.async {
                self.tableView?.reloadData()
                self.tableView!.slk_scrollToBottom(animated: true)
            }
            var numComments : Int = Int((self.postData?._numComments)!)
            numComments += 1
            self.postData?._numComments = NSNumber(integerLiteral: numComments)
            APIClient.sharedInstance.updatePostInfo(post: self.postData!)
        }
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
    
    // -----------------------
    // TABLE VIEW DATA METHODS
    // -----------------------
    
    //these four functions are a hacky way of setting the cell spacing
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // There is just one row in every section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    // Set the spacing between sections
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 4
//    }
//    
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
        let curComment = comments[indexPath.row]
        cell.commentBody.text = curComment?._commentBody
        let url = URL(string: (curComment?._photoURL)!)
        var data = Data()
        do {
            
            data = try Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            cell.profilePic.image = UIImage(data: data)
        } catch {
            cell.profilePic.image = UIImage(named: "UserIcon")
        }
//        let chatBubble = UIView(frame: CGRect(x:  cell.commentBody.frame.minX, y: cell.commentBody.frame.minY, width:  cell.commentBody.frame.width, height:  cell.commentBody.frame.height))
//        chatBubble.layer.cornerRadius = 19;
//        chatBubble.backgroundColor = UIColor(red: 220/255, green:220/255, blue: 220/255, alpha: 1.0)
//        cell.addSubview(chatBubble)
        return cell
    }
    

}
