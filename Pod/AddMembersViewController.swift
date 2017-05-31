//
//  AddMembersViewController.swift
//  Pod
//
//  Created by Max Freundlich on 5/30/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class AddMembersViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var friendTableView: UITableView!
    
    var pod: PodList?
    var friends: [UserInformation] = []
    var members: [UserInformation] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = pod?._name
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        friendTableView.delegate = self
        friendTableView.dataSource = self
        friendTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        friendTableView.backgroundColor = .lightBlue
        view.backgroundColor = .lightBlue
        for friend in FacebookIdentityProfile._sharedInstance.inAppFriends!{
            if !members.contains(where: { $0._facebookId == friend._facebookId }) {
                friends.append(friend)
            }
        }
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        friends.removeAll()
        members.removeAll()
        friendTableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendInvites(_ sender: Any) {
        print("send out invites")
    }

    @IBAction func goBack(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
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

extension AddMembersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AddMemberTableViewCell
        if(cell.checkedImage.isHidden){
            cell.backgroundColor = UIColor(red: 202/255, green: 234/255, blue: 249/255, alpha: 1)
            cell.checkedImage.image = UIImage(named: "checkMark")
            cell.checkedImage.isHidden = false
        } else {
            cell.backgroundColor = .lightBlue
            cell.checkedImage.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddMemberTableViewCell") as! AddMemberTableViewCell
        cell.userName.text = friends[indexPath.row]._username
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        let url = URL(string: friends[indexPath.row]._photoURL!)
        var data = Data()
        do {
            data = try Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            cell.profilePicture.image = UIImage(data: data)
        } catch {
            cell.profilePicture.image = UIImage(named: "UserIcon")
        }
        return cell
    }
    
}

