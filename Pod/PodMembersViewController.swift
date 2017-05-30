//
//  PodMembersViewController.swift
//  Pod
//
//  Created by Max Freundlich on 5/30/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class PodMembersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var podTitle: UILabel!
    
    var pod: Pod?

    override func viewDidLoad() {
        super.viewDidLoad()
        podTitle.text = pod?.name
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.estimatedRowHeight = 20.0 // Replace with your actual estimation
        // Automatic dimensions to tell the table view to use dynamic height
        tableView.rowHeight = UITableViewAutomaticDimension
        // self.textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.backgroundColor = .lightBlue
        view.backgroundColor = .lightBlue
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
        print("add members")
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
        return (pod?.userNameList.count)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected!")
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberTableViewCell") as! MemberTableViewCell
        cell.name.text = pod?.userNameList[indexPath.row]
        cell.profilePic.image = UIImage(named: "profile-pic")
        return cell
    }
    
}
