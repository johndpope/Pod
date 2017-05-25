//
//  PodPrivacyViewController.swift
//  Pod
//
//  Created by Max Freundlich on 5/24/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class PodPrivacyViewController: UIViewController {

    @IBOutlet weak var privacyImage: UIImageView!
    @IBOutlet weak var privacyText: UILabel!
    
    var podTitle: String = ""
    var isPrivate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        privacyImage.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(setPrivacy))
        privacyImage.addGestureRecognizer(tapRecognizer)
        // Do any additional setup after loading the view.
    }

    func setPrivacy(gesture: UITapGestureRecognizer) {
        if(isPrivate){
            privacyImage.image = UIImage(named: "icons8-unlock")
            privacyText.text = "Tap the lock to make this pod public"
            isPrivate = false;
        } else {
            privacyImage.image = UIImage(named: "icons8-lock")
            privacyText.text = "Tap the lock to make this pod private"
            isPrivate = true;
        }

    }
    
    @IBAction func createPod(_ sender: Any) {
        print("Creating pod: \(podTitle). Private: \(isPrivate)")
        dismiss(animated: true, completion: nil)
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
