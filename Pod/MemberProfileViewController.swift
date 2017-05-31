//
//  MemberProfileViewController.swift
//  Pod
//
//  Created by Max Freundlich on 5/30/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class MemberProfileViewController: UIViewController {

    @IBOutlet weak var faacebookButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    var member: UserInformation?
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: (member?._photoURL)!)
        var data = Data()
        do {
            data = try Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            profileImage.image = UIImage(data: data)
        } catch {
            profileImage.image = UIImage(named: "UserIcon")
        }
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
        userName.text = member?._username
        
        faacebookButton.backgroundColor = UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 1)
        faacebookButton.layer.cornerRadius = 8
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

    @IBAction func openFacebookProfile(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: (member?._profileURL)!)! as URL)
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
