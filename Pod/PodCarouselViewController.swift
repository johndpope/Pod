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
    @IBOutlet weak var podsNearbyLabel: UILabel!
    @IBOutlet weak var peopleInPod: UILabel!
    
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
        presentSignInViewController()
        self.navigationController?.isNavigationBarHidden = true
        carousel.type = .rotary
        addButton.setImage(UIImage(named:"addIcon"), for: UIControlState.normal)
        addButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        addButton.tintColor = UIColor.white
        FacebookIdentityProfile._sharedInstance.load()
        FacebookIdentityProfile._sharedInstance.getFriendsOnApp()
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
            APIClient().getPostForPod(withId: (pod.podID), index: i, completion: { (posts, j) in
                if(j != -1){
                    self.items[j].postData = posts as! [Posts]
                    self.carousel.reloadData()
                }
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
        if self.items[self.carousel.currentItemIndex].userIdList.count > 1 || self.items[self.carousel.currentItemIndex].userIdList.count == 0{
            self.peopleInPod.text = "\(self.items[self.carousel.currentItemIndex].userIdList.count) people"
        } else {
            self.peopleInPod.text = "\(self.items[self.carousel.currentItemIndex].userIdList.count) person"
        }
        return podView
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        let index = carousel.currentItemIndex
        if(items.isEmpty != true){
            self.podTitle.text = items[index].name
            if self.items[index].userIdList.count == 0 || self.items[index].userIdList.count > 1{
                self.peopleInPod.text = "\(self.items[index].userIdList.count) people"
            } else {
                self.peopleInPod.text = "\(self.items[index].userIdList.count) person"
            }
        }
    }
    
}

// MARK: - PodView Methods

extension PodCarouselViewController: PodViewDelegate {
    func toSinglePod(_ podView: Pod) {
        performSegue(withIdentifier: Constants.Storyboard.SinglePodSegueId, sender: podView)
    }
}
