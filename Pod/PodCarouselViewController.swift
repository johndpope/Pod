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
import CoreLocation

class PodCarouselViewController: UIViewController {
    
    // MARK: - Properties
    
    var items: [PodStruct] = []
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
    // MARK: - PodCarouselViewController
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //for i in 0 ... 99 {
         //   items.append(i)
        //}
        let content = ["name":"Adah M.","postBody":"Come to the lougne for the hosue meeting!", "numHearts": 26, "numComments": 6] as Dictionary<String, Any>
        let content1 = ["name":"Mohammed S.","postBody":"Push me to the edge! All my friends are dead! Push me to the edge! all my friends are dead! 2017 .....", "numHearts": 26, "numComments": 6] as Dictionary<String, Any>
        let content2 = ["name":"Marjory B.","postBody":"I'm selling two tickets to see XXXTENTACION if anyone is interested! $40/each :)", "numHearts": 26, "numComments": 6] as Dictionary<String, Any>

        let p1 = PodStruct(title: "Arroyo Dorm", postData: [content as NSDictionary, content1 as NSDictionary, content2 as NSDictionary])
        let p2 = PodStruct(title: "Arroyo Dorm", postData: [content as NSDictionary, content1 as NSDictionary, content2 as NSDictionary])
        let p3 = PodStruct(title: "Arroyo Dorm", postData: [content as NSDictionary, content1 as NSDictionary, content2 as NSDictionary])
        let p4 = PodStruct(title: "Arroyo Dorm", postData: [content as NSDictionary, content1 as NSDictionary, content2 as NSDictionary])

        items.append(p1)
        items.append(p2)
        items.append(p3)
        items.append(p4)
        items.append(p4)
        items.append(p4)
        items.append(p4)
        items.append(p4)
        items.append(p4)
        items.append(p4)
        items.append(p4)
        items.append(p4)
        items.append(p4)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        carousel.type = .rotary
        print(AWSSignInManager.sharedInstance().isLoggedIn)
        let client = APIClient()
        let location = CLLocationCoordinate2D(latitude: 37.4204870, longitude: -122.1714210)
        client.getNearbyPods(location: location) { 
            print("done")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if(segue.identifier == Constants.Storyboard.SinglePodSegueId){
            if let nextVC = segue.destination as? PodViewController {
                let podView = sender as! PodStruct
                nextVC.podData = podView
            }
        }
    }

}

// MARK: - iCarousel Methods

extension PodCarouselViewController: iCarouselDataSource, iCarouselDelegate {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return items.count
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.2
        }
        return value
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let podView = (view as? PodView != nil) ? view as! PodView : PodView(frame: CGRect(x: 0, y: 0, width: 255, height: 453))
        podView.delegate = self
        podView.podData = items[index]
        return podView
    }
}

// MARK: - PodView Methods

extension PodCarouselViewController: PodViewDelegate {
    func toSinglePod(_ podView: PodStruct) {
        performSegue(withIdentifier: Constants.Storyboard.SinglePodSegueId, sender: podView)

    }
}

class PodStruct {
    var title: String?
    var postData: [NSDictionary?]
    
    init(title: String, postData: [NSDictionary]) {
        self.title = title
        self.postData = postData
    }
    
    
}
