//
//  PodMembersViewController.swift
//  Pod
//
//  Created by Max Freundlich on 5/30/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class PodMembersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var podTitle: UILabel!
    
    var pod: PodList?
    var members: [UserInformation] = []

    @IBOutlet weak var addMembersButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        podTitle.text = pod?._name
        podTitle.font = UIFont.boldSystemFont(ofSize: 18)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        addMembersButton.isHidden = true
       // tableView.estimatedRowHeight = 40.0 // Replace with your actual estimation
        // Automatic dimensions to tell the table view to use dynamic height
       // tableView.rowHeight = UITableViewAutomaticDimension
        // self.textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
       // tableView.setNeedsLayout()
        //tableView.layoutIfNeeded()
        tableView.backgroundColor = .lightBlue
        view.backgroundColor = .lightBlue
        for id in (pod?._userIdList)!{
            if(id == FacebookIdentityProfile._sharedInstance.userId!){
                addMembersButton.isHidden = false
            }
            APIClient().getUser(withId: id, completion: { (uinfo) in
                if(uinfo != nil){
                    self.members.append(uinfo!)
                    self.tableView.reloadData()
                }
            })
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func goBack(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func addMembers(_ sender: Any) {
        self.performSegue(withIdentifier: "toAddMembersView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if(segue.identifier == "toMemberProfileView"){
            if let nextVC = segue.destination as? MemberProfileViewController {
                nextVC.member = sender as! UserInformation
            }
        } else if(segue.identifier == "toAddMembersView"){
            if let nextVC = segue.destination as? AddMembersViewController {
                nextVC.pod = self.pod
                nextVC.members = self.members
            }
        }
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
extension PodMembersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "toMemberProfileView", sender: members[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        var cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor(red: 202/255, green: 234/255, blue: 249/255, alpha: 1)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        var cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = .lightBlue
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberTableViewCell") as! MemberTableViewCell
        cell.name.text = members[indexPath.row]._username
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let url = URL(string: members[indexPath.row]._photoURL!)
        var data = Data()
        do {
            data = try Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            cell.profilePic.image = UIImage(data: data)
        } catch {
            cell.profilePic.image = UIImage(named: "UserIcon")
        }
        return cell
    }
    
}
