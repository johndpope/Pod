//
//  AddMembersViewController.swift
//  Pod
//
//  Created by Max Freundlich on 5/30/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit
import Haneke

class AddMembersViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var friendTableView: UITableView!
    
    var pod: PodList?
    var friends: [UserInformation] = []
    var allFriends: [UserInformation] = []
    var members: [UserInformation] = []
    var inviteList: Set<Int> = []


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
        for friend in FacebookIdentityProfile._sharedInstance.taggableFriends!{
            if !members.contains(where: { $0._facebookId == friend._facebookId }) {
                allFriends.append(friend)
            }
        }
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        friends.removeAll()
        members.removeAll()
        allFriends.removeAll()
        friendTableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendInvites(_ sender: Any) {
        var invites: [UserInformation] = []
        for i in inviteList{
            invites.append(friends[i])
        }
        for invite in invites {
            APIClient.sharedInstance.sendRequest(toUser: invite._facebookId!, forPod: (pod?._podId)!, geoHash: (pod?._geoHashCode)!, type: RequestType.invite)
        }
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return friends.count
        case 1:
            return allFriends.count
        default:
             return 0
        }
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AddMemberTableViewCell
        if(cell.checkedImage.isHidden){
            cell.backgroundColor = UIColor(red: 202/255, green: 234/255, blue: 249/255, alpha: 1)
            cell.checkedImage.image = UIImage(named: "checkMark")
            cell.checkedImage.isHidden = false
            inviteList.insert(indexPath.row)
        } else {
            cell.backgroundColor = .lightBlue
            cell.checkedImage.isHidden = true
            inviteList.remove(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Friends Using Pod"
        case 1:
            return "All Friends"
        default:
            return ""
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddMemberTableViewCell") as! AddMemberTableViewCell
        var uInfo = UserInformation()
        if indexPath.section == 0{
            uInfo = friends[indexPath.row]
        } else {
            uInfo = allFriends[indexPath.row]
        }
        cell.userName.text = uInfo?._username
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        
        let cache = Shared.dataCache
        cache.fetch(key: (uInfo?._photoURL!)!).onSuccess({ (data) in
            cell.profilePicture.image = UIImage(data: data)
        }).onFailure({ (err) in
            let url = URL(string: (uInfo?._photoURL!)!)
            var data = Data()
            do {
                data = try Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                cell.profilePicture.image = UIImage(data: data)
                cache.set(value: data, key: (uInfo?._photoURL!)!)
            } catch {
                cell.profilePicture.image = UIImage(named: "UserIcon")
            }
            
        })
        return cell
    }
    
}

