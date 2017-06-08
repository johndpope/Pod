//
//  InviteRequestViewController.swift
//  Pod
//
//  Created by Max Freundlich on 5/31/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class InviteRequestViewController: UIViewController, InviteTableViewAcceptDelegate {

    @IBOutlet weak var tableView: UITableView!
    var requests: [PodRequests] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = .lightBlue
        tableView?.estimatedRowHeight = 60.0 // Replace with your actual estimation
        // Automatic dimensions to tell the table view to use dynamic height
        tableView?.rowHeight = UITableViewAutomaticDimension
        // self.textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView?.allowsSelection = false
        tableView?.setNeedsLayout()
        tableView?.layoutIfNeeded()
        view.backgroundColor = .lightBlue
        // Do any additional setup after loading the view.
        APIClient.sharedInstance.getPodRequestsForCurrentUser { (reqs) in
            for req in reqs {
                self.requests.append(req!)
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func backButton(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func didPressAccept(_ tag: Int) {
        //Wait half a second to show UI changes
        let req = self.requests[tag]
        if Int(req._requestType!) == RequestType.invite.hashValue{
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1) , execute: {
                APIClient.sharedInstance.acceptPodInvitation(request: self.requests[tag])
                self.requests.remove(at: tag)
                self.tableView.reloadData()
            })
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1) , execute: {
                APIClient.sharedInstance.acceptJoinRequest(request: self.requests[tag])
                self.requests.remove(at: tag)
                self.tableView.reloadData()
            })
        }

    }
    
    func didPressCancel(_ tag: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1) , execute: {
            APIClient.sharedInstance.declinePodInvitation(request: self.requests[tag])
            self.requests.remove(at: tag)
            self.tableView.reloadData()
        })
    }

}


extension InviteRequestViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requests.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InviteTableViewCell") as! InviteTableViewCell
        cell.cellDelegate = self
        cell.tag = indexPath.row
        let req = self.requests[indexPath.row]
        if(Int(req._requestType!) == RequestType.invite.hashValue){
            cell.requestLabel.text = "\(req._senderName!) invited you to join \(req._podName!)!"
        } else {
            cell.requestLabel.text = "\(req._senderName!) wants to join your Pod \(req._podName!)"
        }
        let url = URL(string: req._senderPhotoURL!)
        var data = Data()
        do {
            data = try Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            cell.profilePic.image = UIImage(data: data)
        } catch {
            cell.profilePic.image = UIImage(named: "UserIcon")
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
}
