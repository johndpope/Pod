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
    
    var items: [Pod] = []
    @IBOutlet var carousel: iCarousel!
    @IBOutlet var addButton: UIButton!
    @IBOutlet weak var podTitle: UILabel!
    
    var isPresentingForFirstTime = true
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentSignInViewController()
        self.navigationController?.isNavigationBarHidden = true
        carousel.type = .rotary
        addButton.setImage(UIImage(named:"addIcon"), for: UIControlState.normal)
        addButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        addButton.tintColor = UIColor.white
        FacebookIdentityProfile._sharedInstance.load()
    }
    
    func getAllPods(){
        let client = APIClient()
        let location = CLLocationCoordinate2D(latitude: 37.4204870, longitude: -122.1714210)
        client.getNearbyPods(location: location) { (pods) in
            for pod in pods! {
                //APIClient().uploadTestPostsToPod(withId: pod.podID)
                if !self.items.contains(where: { $0.podID == pod.podID }) {
                    self.items.append(pod)
                }
            }
            self.getLimitedPostsForPods()
        }
        
    }
    
    func getLimitedPostsForPods(){
        for i in 0..<self.items.count{
            let pod = self.items[i]
            APIClient().getPostForPod(withId: (pod.podID), index: i, completion: { (posts, index) in
                self.items[index].postData = posts as! [Posts]
                self.carousel.reloadData()
            })
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if(segue.identifier == Constants.Storyboard.SinglePodSegueId){
            if let nextVC = segue.destination as? PodViewController {
                let podView = sender as! Pod
                nextVC.podData = podView
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllPods()
    }
    
    func onSignIn (_ success: Bool) {
        // handle successful sign in
        if (success) {
            APIClient.sharedInstance.initClientInfo()
            getAllPods()
            FacebookIdentityProfile._sharedInstance.load()
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
        } else {
            FacebookIdentityProfile().getFriendsOnApp()
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
        self.podTitle.text = self.items[self.carousel.currentItemIndex].name
        return podView
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        let index = carousel.currentItemIndex
        if(items.isEmpty != true){
            self.podTitle.text = items[index].name
        }
    }
    
}

// MARK: - PodView Methods

extension PodCarouselViewController: PodViewDelegate {
    func toSinglePod(_ podView: Pod) {
        performSegue(withIdentifier: Constants.Storyboard.SinglePodSegueId, sender: podView)
    }
}
