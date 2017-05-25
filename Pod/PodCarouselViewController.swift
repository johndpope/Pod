//
//  ViewController.swift
//  SwiftExample
//
//  Created by Nick Lockwood on 30/07/2014.
//  Copyright (c) 2014 Charcoal Design. All rights reserved.
//

import UIKit
import AWSCore
import AWSMobileHubHelper

class PodCarouselViewController: UIViewController {
    var items: [String] = []
    @IBOutlet var carousel: iCarousel!

    @IBAction func signOut(_ sender: Any) {
        if (AWSSignInManager.sharedInstance().isLoggedIn) {
            AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?, authState: AWSIdentityManagerAuthState, error: Error?) in
                print("go to sign in view controller")
            })
            // print("Logout Successful: \(signInProvider.getDisplayName)");
        } else {
            assert(false)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        //for i in 0 ... 99 {
         //   items.append(i)
        //}
        items.append("Arroyo Dorm")
        items.append("Old Union")
        items.append("Toyon")
        items.append("Tressider")
        items.append("CoHo")

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        carousel.type = .cylinder
        print(AWSSignInManager.sharedInstance().isLoggedIn)
    }
}

// MARK: - iCarousel Methods

extension PodCarouselViewController: iCarouselDataSource, iCarouselDelegate {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return items.count
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.1
        }
        return value
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let blah = (view as? PodView != nil) ? view as! PodView : PodView(frame: CGRect(x: 0, y: 0, width: 255, height: 453))
        return blah
    }
}
