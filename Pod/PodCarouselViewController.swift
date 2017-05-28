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
    @IBOutlet var addButton: UIButton!
    @IBOutlet weak var podTitle: UILabel!

    @IBAction func signOut(_ sender: Any) {
        if (AWSSignInManager.sharedInstance().isLoggedIn) {
            AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?, authState: AWSIdentityManagerAuthState, error: Error?) in
                self.navigationController!.popToRootViewController(animated: false)
                self.presentSignInViewController()
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
        let arroyoContent = PostDetails(posterName: "Arroyo", postText: "Come to the lougne for the hosue meeting!", numHearts: 13, numComments: 4)
        let sixEightyContent = PostDetails(posterName: "680", postText: "Come to the lougne for the hosue meeting!", numHearts: 13, numComments: 4)
        let gatesContent = PostDetails(posterName: "Gates", postText: "Come to the lougne for the hosue meeting!", numHearts: 13, numComments: 4)
        let oldUnionContent = PostDetails(posterName: "Old Union", postText: "Come to the lougne for the hosue meeting!", numHearts: 13, numComments: 4)

        let content = PostDetails(posterName: "Adad M.", postText: "Push me to the edge! All my friends are dead! Push me to the edge! all my friends are dead! 2017", numHearts: 26, numComments: 6)
        let content1 = PostDetails(posterName: "Mohammaed S.", postText: "Come to the lougne for the hosue meeting!", numHearts: 13, numComments: 4)
        let content2 = PostDetails(posterName: "Marjory B.", postText: "I'm selling two tickets to see XXXTENTACION if anyone is interested! $40/each :)", numHearts: 51, numComments: 21)


        let p1 = PodStruct(title: "Arroyo Dorm", postData: [arroyoContent, content, content1, content2])
        let p2 = PodStruct(title: "680", postData: [sixEightyContent, content, content1, content2])
        let p3 = PodStruct(title: "Gates", postData: [gatesContent, content, content1, content2])
        let p4 = PodStruct(title: "Old Union", postData: [oldUnionContent, content, content1, content2])

        items.append(p1)
        items.append(p2)
        items.append(p3)
        items.append(p4)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presentSignInViewController()
        self.navigationController?.isNavigationBarHidden = true
        carousel.type = .rotary
        addButton.setImage(UIImage(named:"addIcon"), for: UIControlState.normal)
        addButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        addButton.tintColor = UIColor.white

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if(segue.identifier == Constants.Storyboard.SinglePodSegueId){
            if let nextVC = segue.destination as? PodViewController {
                let podView = sender as! PodStruct
                nextVC.podData = podView
            }
        }
    }
    
    func onSignIn (_ success: Bool) {
        // handle successful sign in
        if (success) {
            let client = APIClient()
            let location = CLLocationCoordinate2D(latitude: 37.4204870, longitude: -122.1714210)
            client.getNearbyPods(location: location) {
                print("done")
            }
            APIClient.sharedInstance.initClientInfo()
            self.podTitle.text = items[0].title
        } else {
            // handle cancel operation from user
        }
    }
    
    func presentSignInViewController() {
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            let loginStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
            let loginController: SignInViewController = loginStoryboard.instantiateViewController(withIdentifier: "SignIn") as! SignInViewController
            loginController.canCancel = false
            loginController.didCompleteSignIn = onSignIn
            let navController = UINavigationController(rootViewController: loginController)
            navigationController?.present(navController, animated: true, completion: nil)
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
    
//    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
//        self.podTitle.isHidden = false
//    }
//    
//    func carouselWillBeginScrollingAnimation(_ carousel: iCarousel) {
//        self.podTitle.isHidden = true
//    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let podView = (view as? PodView != nil) ? view as! PodView : PodView(frame: CGRect(x: 0, y: 0, width: 255, height: 453))
        podView.delegate = self
        podView.podData = items[index]
        self.podTitle.text = items[index].title
        return podView
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        let index = carousel.currentItemIndex
        self.podTitle.text = items[index].title
    }
    
}

// MARK: - PodView Methods

extension PodCarouselViewController: PodViewDelegate {
    func toSinglePod(_ podView: PodStruct) {
        performSegue(withIdentifier: Constants.Storyboard.SinglePodSegueId, sender: podView)
    }
}
