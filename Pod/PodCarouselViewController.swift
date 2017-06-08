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
import Haneke

class PodCarouselViewController: UIViewController, JoinPodDelegate {
    
    // MARK: - Properties
    
    var items: [PodList] = []
    @IBOutlet var carousel: iCarousel!
    @IBOutlet var addButton: UIButton!
    @IBOutlet weak var podTitle: UILabel!
    @IBOutlet weak var podsNearbyLabel: UILabel!
    @IBOutlet weak var peopleInPod: UILabel!
    
    @IBOutlet weak var myPodsButton: UIButton!
    
    @IBOutlet weak var mapButton: UIButton!
    var isPresentingForFirstTime = true
    var numAdded = 0
    private lazy var userImage1: UIImageView = {
        let userImage1 = UIImageView()
        userImage1.image = UIImage(named: "UserIcon")
        return userImage1
    }()
    private lazy var userImage2: UIImageView = {
        let userImage2 = UIImageView()
        userImage2.image = UIImage(named: "UserIcon")
        return userImage2
    }()
    private lazy var userImage3: UIImageView = {
        let userImage3 = UIImageView()
        userImage3.image = UIImage(named: "UserIcon")
        return userImage3
    }()
    private lazy var userImage4: UIImageView = {
        let userImage4 = UIImageView()
        userImage4.image = UIImage(named: "UserIcon")
        return userImage4
    }()
    
//    lazy var memberLabel: UILabel = {
//        let memberLabel = UILabel()
//        memberLabel.text = "Member"
//        memberLabel.textColor = .white
//        memberLabel.backgroundColor = .gray
//        memberLabel.isHidden = true
//        memberLabel.textAlignment = NSTextAlignment.center
//        return memberLabel
//    }()
    
    private lazy var notificationBubble: UILabel = {
        let notificationBubble = UILabel(frame: CGRect(x: 0, y: 0, width: 20.0, height: 20.0))
        notificationBubble.backgroundColor = .red
        notificationBubble.textColor = .white
        notificationBubble.textAlignment = .center
        notificationBubble.layer.cornerRadius = notificationBubble.bounds.size.width / 2.0
        notificationBubble.layer.masksToBounds = true
        notificationBubble.isHidden = true
        return notificationBubble
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightBlue
        presentSignInViewController()
        self.navigationController?.isNavigationBarHidden = true
        carousel.type = .rotary
        setUpButtons()
        FacebookIdentityProfile._sharedInstance.load()
        FacebookIdentityProfile._sharedInstance.getFriendsOnApp()
        //FacebookIdentityProfile._sharedInstance.getTaggableFriends()
        carousel.scrollSpeed = 0.5
        let loc = CLLocationCoordinate2D(latitude: 37.4204870, longitude: -122.1714210)
        APIClient.sharedInstance.getExplorePods(location: loc, length: "8")
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
    
    override func viewDidLayoutSubviews() {
        //        userImage1.layer.borderWidth = 1
        //        userImage1.layer.masksToBounds = false
        //        userImage1.layer.cornerRadius = userImage1.frame.height/2
        //        userImage1.clipsToBounds = true
    }
    
    // MARK: - Helper Methods
    
    private func setupUser1Image(data: Data){
        view.insertSubview(userImage1.usingAutolayout(), belowSubview: carousel)
        userImage1.image = UIImage(data: data)
        userImage1.layer.masksToBounds = false
        userImage1.layer.cornerRadius = 25/2
        userImage1.clipsToBounds = true
        NSLayoutConstraint.activate([
            userImage1.centerYAnchor.constraint(equalTo: peopleInPod.centerYAnchor),
            userImage1.rightAnchor.constraint(equalTo: peopleInPod.leftAnchor, constant: -8),
            userImage1.widthAnchor.constraint(equalToConstant: 25),
            userImage1.heightAnchor.constraint(equalToConstant: 25),
            ])
    }
    
    private func setupUser2Image(data: Data){
        view.insertSubview(userImage2.usingAutolayout(), belowSubview: carousel)
        userImage2.image = UIImage(data: data)
        userImage2.layer.masksToBounds = false
        userImage2.layer.cornerRadius = 25/2
        userImage2.clipsToBounds = true
        NSLayoutConstraint.activate([
            userImage2.centerYAnchor.constraint(equalTo: peopleInPod.centerYAnchor),
            userImage2.rightAnchor.constraint(equalTo: peopleInPod.leftAnchor, constant: -22),
            userImage2.widthAnchor.constraint(equalToConstant: 25),
            userImage2.heightAnchor.constraint(equalToConstant: 25),
            ])
    }
    
    private func setupUser3Image(data: Data){
        view.insertSubview(userImage3.usingAutolayout(), belowSubview: carousel)
        userImage3.image = UIImage(data: data)
        userImage3.layer.masksToBounds = false
        userImage3.layer.cornerRadius = 25/2
        userImage3.clipsToBounds = true
        NSLayoutConstraint.activate([
            userImage3.centerYAnchor.constraint(equalTo: peopleInPod.centerYAnchor),
            userImage3.rightAnchor.constraint(equalTo: peopleInPod.leftAnchor, constant: -39),
            userImage3.widthAnchor.constraint(equalToConstant: 25),
            userImage3.heightAnchor.constraint(equalToConstant: 25),
            ])
    }
    
    private func setupUser4Image(data: Data){
        view.insertSubview(userImage4.usingAutolayout(), belowSubview: carousel)
        userImage4.image = UIImage(data: data)
        userImage4.layer.masksToBounds = false
        userImage4.layer.cornerRadius = 25/2
        userImage4.clipsToBounds = true
        NSLayoutConstraint.activate([
            userImage4.centerYAnchor.constraint(equalTo: peopleInPod.centerYAnchor),
            userImage4.rightAnchor.constraint(equalTo: peopleInPod.leftAnchor, constant: -53),
            userImage4.widthAnchor.constraint(equalToConstant: 25),
            userImage4.heightAnchor.constraint(equalToConstant: 25),
            ])
    }
    
//    func setupMemberLabel(){
//        NSLayoutConstraint.activate([
//            memberLabel.bottomAnchor.constraint(equalTo: self.carousel.topAnchor, constant: -10),
//            memberLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//            memberLabel.widthAnchor.constraint(equalToConstant: 75)
//            ])
//    }
    
    func setUpButtons() {

        // Add Button
        addButton.setImage(UIImage(named:"addIcon"), for: .normal)
        addButton.tintColor = .white
        addButton.backgroundColor = .darkBlue
        addButton.layer.cornerRadius = 0.5 * addButton.bounds.size.width
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOpacity = 0.5
        addButton.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        addButton.layer.shadowRadius = 2.0
        
        // My Pods Button
        myPodsButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        myPodsButton.tintColor = UIColor.white
        myPodsButton.backgroundColor = .darkBlue
        myPodsButton.layer.cornerRadius = 0.5 * addButton.bounds.size.width
        myPodsButton.layer.shadowColor = UIColor.black.cgColor
        myPodsButton.layer.shadowOpacity = 0.5
        myPodsButton.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        myPodsButton.layer.shadowRadius = 2.0
        view.addSubview(notificationBubble)
        notificationBubble.center = CGPoint(x: Double(myPodsButton.center.x) + Double(myPodsButton.bounds.width) * 0.5 * cos(45.0 * .pi / 180.0), y: Double(myPodsButton.center.y) - Double(myPodsButton.bounds.height * 0.5) * sin(45.0 * .pi / 180.0))
        
        // Map Button
        mapButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        mapButton.tintColor = UIColor.white
        mapButton.backgroundColor = .darkBlue
        mapButton.layer.cornerRadius = 0.5 * addButton.bounds.size.width
        mapButton.layer.shadowColor = UIColor.black.cgColor
        mapButton.layer.shadowOpacity = 0.5
        mapButton.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        mapButton.layer.shadowRadius = 2.0
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
                let rev = Array(posts.reversed())
                self.items[j].postData = rev as! [Posts]
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
    
    func getNotifications(){
        APIClient.sharedInstance.getPodRequestsForCurrentUser { (requests) in
            if(requests.count > 0){
                self.showNotificationBubble(true, withNumber: requests.count)
            } else {
                self.showNotificationBubble(false)
            }
        }
    }
    
    func onSignIn (_ success: Bool) {
        // handle successful sign in
        if (success) {
            APIClient.sharedInstance.initClientInfo()
            FacebookIdentityProfile._sharedInstance.load()
            //FacebookIdentityProfile._sharedInstance.getTaggableFriends()
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
    
    private func showNotificationBubble(_ show: Bool, withNumber number: Int = 0) {
        notificationBubble.isHidden = !show
        notificationBubble.text = String(number)
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
            APIClient.sharedInstance.sendJoinRequest(pod: podView.podData!)
        }
        
        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setUpFriendsCircle(index: Int){
        self.podTitle.text = self.items[index]._name
        let item = self.items[index]
        let numPeople = item._userIdList?.count
        
        if numPeople == 0{
            self.peopleInPod.text = "\(String(describing: (item._userIdList?.count)!)) people"
        } else if numPeople == 1 {
            if(item._userIdList?.contains(FacebookIdentityProfile._sharedInstance.userId!))!{
                self.peopleInPod.text = "You are the only member"
            } else {
                self.peopleInPod.text = "1 person"
            }
        } else {
            if(item._userIdList?.contains(FacebookIdentityProfile._sharedInstance.userId!))!{
                if(item._userIdList?.count == 2){
                    self.peopleInPod.text = "You and 1 other person"
                } else {
                    self.peopleInPod.text = "You and \(numPeople!-1) other people"
                }
            } else {
                self.peopleInPod.text = "\(String(describing: numPeople!)) people"
            }
        }
        switch numAdded {
        case 1:
            userImage1.removeFromSuperview()
            break
        case 2:
            userImage1.removeFromSuperview()
            userImage2.removeFromSuperview()
            break
        case 3:
            userImage1.removeFromSuperview()
            userImage2.removeFromSuperview()
            userImage3.removeFromSuperview()
            break
        case 4:
            userImage1.removeFromSuperview()
            userImage2.removeFromSuperview()
            userImage3.removeFromSuperview()
            userImage4.removeFromSuperview()
            break
        default:
            break
        }
        numAdded = 0
        for (i, id) in (item._userIdList?.enumerated())! {
            if numAdded == 4 {
                return
            }
            
            if FacebookIdentityProfile._sharedInstance.userId == id {
                numAdded += 1
                let cache = Shared.dataCache
                cache.fetch(key: id).onSuccess({ (data) in
                    if i == 0 {
                        self.setupUser1Image(data: data)
                    } else if i == 1{
                        self.setupUser2Image(data: data)
                    } else if i == 2{
                        self.setupUser3Image(data: data)
                    } else if i == 3{
                        self.setupUser4Image(data: data)
                    }
                }).onFailure({ (err) in
                    var data = Data()
                    do {
                        data = try Data(contentsOf: FacebookIdentityProfile._sharedInstance.imageURL!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                        if i == 0 {
                            self.setupUser1Image(data: data)
                        } else if i == 1{
                            self.setupUser2Image(data: data)
                        } else if i == 2{
                            self.setupUser3Image(data: data)
                        } else if i == 3{
                            self.setupUser4Image(data: data)
                        }
                        cache.set(value: data, key: id)
                    } catch {
                        
                    }
                })
            } else if FacebookIdentityProfile._sharedInstance.inAppFriendsIds.contains(id){
                numAdded += 1
                let cache = Shared.dataCache
                cache.fetch(key: id).onSuccess({ (data) in
                    if i == 0 {
                        self.setupUser1Image(data: data)
                    } else if i == 1{
                        self.setupUser2Image(data: data)
                    } else if i == 2{
                        self.setupUser3Image(data: data)
                    } else if i == 3{
                        self.setupUser4Image(data: data)
                    }
                }).onFailure({ (err) in
                    APIClient.sharedInstance.getUser(withId: id, completion: { (uInfo) in
                        let url = URL(string: (uInfo?._photoURL)!)
                        var data = Data()
                        do {
                            data = try Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                            if i == 0 {
                                self.setupUser1Image(data: data)
                            } else if i == 1{
                                self.setupUser2Image(data: data)
                            } else if i == 2{
                                self.setupUser3Image(data: data)
                            } else if i == 3{
                                self.setupUser4Image(data: data)
                            }
                            cache.set(value: data, key: id)
                        } catch {
                            
                        }
                    })
                    
                })
            }
        }

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
        //self.setUpFriendsCircle(index: carousel.currentItemIndex)
        return podView
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        let index = carousel.currentItemIndex
        if(items.isEmpty != true){
            self.setUpFriendsCircle(index: index)
        }
    }
    
}

// MARK: - PodView Methods

extension PodCarouselViewController: PodViewDelegate {
    func toSinglePod(_ podView: PodList) {
        performSegue(withIdentifier: Constants.Storyboard.SinglePodSegueId, sender: podView)
    }
}
