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
    
    func getAllPods(){
//        client.getNearbyPods(location: location) {
//            print("done")
//        }
        
        let client = APIClient()
        let location = CLLocationCoordinate2D(latitude: 37.4204870, longitude: -122.1714210)
        client.getNearbyPods(location: location) { (pods) in
            self.items = pods!
            self.carousel.reloadData()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllPods()
    }
    
    func onSignIn (_ success: Bool) {
        // handle successful sign in
        if (success) {
            APIClient.sharedInstance.initClientInfo()
            getAllPods()
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
        if(items.isEmpty != true){
            self.podTitle.text = items[index].title

        }
    }
    
}

// MARK: - PodView Methods

extension PodCarouselViewController: PodViewDelegate {
    func toSinglePod(_ podView: PodStruct) {
        performSegue(withIdentifier: Constants.Storyboard.SinglePodSegueId, sender: podView)
    }
}
