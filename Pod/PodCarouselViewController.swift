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

class PodCarouselViewController: UIViewController, JoinPodDelegate {
    
    // MARK: - Properties
    
    var items: [PodList] = []
    @IBOutlet var carousel: iCarousel!
    @IBOutlet var addButton: UIButton!
    @IBOutlet weak var podTitle: UILabel!
    @IBOutlet weak var podsNearbyLabel: UILabel!
    @IBOutlet weak var peopleInPod: UILabel!
    
    @IBOutlet weak var myPodsButton: UIButton!
    
    @IBOutlet weak var redDot: UIImageView!
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
        view.backgroundColor = .lightBlue
        redDot.isHidden = true
        presentSignInViewController()
        self.navigationController?.isNavigationBarHidden = true
        carousel.type = .rotary
        addButton.setImage(UIImage(named:"addIcon"), for: UIControlState.normal)
        addButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        addButton.tintColor = UIColor.white
        FacebookIdentityProfile._sharedInstance.load()
        FacebookIdentityProfile._sharedInstance.getFriendsOnApp()
        carousel.scrollSpeed = 0.5
    }
    
    func getAllPods(){
        let client = APIClient()
        let location = CLLocationCoordinate2D(latitude: 37.4204870, longitude: -122.1714210)
        client.getNearbyPods(location: location) { (pods) in
            DispatchQueue.main.async {
                self.podsNearbyLabel.text = "\((pods?.count)!) Pods near you"
            }
            for pod in pods! {
                //APIClient().uploadTestPostsToPod(withId: pod.podID)
                if !self.items.contains(where: { $0._podId == pod._podId }) {
                    self.items.append(pod)
                } else {
                    for (i,p) in self.items.enumerated() {
                        if p._podId == pod._podId{
                            self.items[i] = pod
                            continue
                        }
                    }
                    
                }
            }
            self.getLimitedPostsForPods()
        }
        
    }
    
    func getLimitedPostsForPods(){
        for i in 0..<self.items.count{
            let pod = self.items[i]
            APIClient().getPostForPod(withId: (pod._podId as! Int), index: i, completion: { (posts, j) in
                self.items[j].postData = posts as! [Posts]
                self.carousel.reloadData()
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if(segue.identifier == Constants.Storyboard.SinglePodSegueId){
            if let nextVC = segue.destination as? PodViewController {
                let podView = sender as! PodList
                nextVC.podData = podView
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllPods()
        if(FacebookIdentityProfile._sharedInstance.userId != nil ){
            getNotifications()
        } else {
            //Try 5 times, every second
            for _ in 0..<5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    if(FacebookIdentityProfile._sharedInstance.userId != nil ){
                        self.getNotifications()
                        return
                    }
                })
            }
        }
    }
    
    func getNotifications(){
        APIClient.sharedInstance.getPodRequestsForCurrentUser { (requests) in
            if(requests.count > 0){
                self.addRedDotNotificationIndicator(show: true)
            } else {
                self.addRedDotNotificationIndicator(show: false)
            }
        }
    }
    
    func onSignIn (_ success: Bool) {
        // handle successful sign in
        if (success) {
            APIClient.sharedInstance.initClientInfo()
            FacebookIdentityProfile._sharedInstance.load()
            FacebookIdentityProfile._sharedInstance.getFriendsOnApp()
            APIClient.sharedInstance.createUser(withId: AWSIdentityManager.default().identityId!, name: FacebookIdentityProfile._sharedInstance.userName!, photoURL: (FacebookIdentityProfile._sharedInstance.imageURL?.absoluteString)!, profileURL: FacebookIdentityProfile._sharedInstance.facebookURL!, faecbookId: FacebookIdentityProfile._sharedInstance.userId!)
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

        }
    }
    
    @IBAction func returnFromSegueActions(_ sender: UIStoryboardSegue) {
    
    }
    
    func addRedDotNotificationIndicator(show: Bool){
        if(show) {
            redDot.isHidden = false
        } else {
            redDot.isHidden = true
        }
    }
    
    func showJoinPodAlert(podView: PodView){
        let alertController = UIAlertController(title: "Request to Join", message: "The creator of this pod set it to private. They must accept your request to join before you can see whats going on inside.", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
        let DestructiveAction = UIAlertAction(title: "Nevermind", style: UIAlertActionStyle.destructive) {
            (result : UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        
        // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
        let okAction = UIAlertAction(title: "Send Request", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            podView.joinButton.setTitle("Request Sent!", for: UIControlState.normal)
            podView.joinButton.isEnabled = false
            if(podView.podData?._userRequestList == nil){
                podView.podData?._userRequestList = [FacebookIdentityProfile._sharedInstance.userId!]
            } else {
                podView.podData?._userRequestList?.append(FacebookIdentityProfile._sharedInstance.userId!)
            }
            APIClient.sharedInstance.updatePod(pod: podView.podData!)
            APIClient.sharedInstance.sendJoinRequest(to: (podView.podData?._createdByUserId)!, podId: podView.podData?._podId as! Int, geoHash: (podView.podData?._geoHashCode)!, podName: (podView.podData?._name)!)
        }
        
        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
protocol JoinPodDelegate {
    func showJoinPodAlert(podView: PodView)
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
        podView.joinDelegate = self
        podView.podData = items[index]
        self.podTitle.text = self.items[self.carousel.currentItemIndex]._name
        if self.items[self.carousel.currentItemIndex]._userIdList!.count > 1 || self.items[self.carousel.currentItemIndex]._userIdList?.count == 0{
            self.peopleInPod.text = "\(String(describing: (self.items[self.carousel.currentItemIndex]._userIdList?.count)!)) people"
        } else {
            self.peopleInPod.text = "\(String(describing: (self.items[self.carousel.currentItemIndex]._userIdList?.count)!)) person"
        }
        return podView
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        let index = carousel.currentItemIndex
        if(items.isEmpty != true){
            self.podTitle.text = items[index]._name
            if (self.items[index]._userIdList?.count)! == 0 || (self.items[index]._userIdList?.count)! > 1{
                self.peopleInPod.text = "\(String(describing: (self.items[index]._userIdList?.count)!)) people"
            } else {
                self.peopleInPod.text = "\(String(describing: (self.items[index]._userIdList?.count)!)) person"
            }
        }
    }
    
}

// MARK: - PodView Methods

extension PodCarouselViewController: PodViewDelegate {
    func toSinglePod(_ podView: PodList) {
        performSegue(withIdentifier: Constants.Storyboard.SinglePodSegueId, sender: podView)
    }
}
