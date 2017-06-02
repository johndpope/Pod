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

class MyPodsCarouselViewController: UIViewController {
    
    // MARK: - Properties
    
    var items: [PodList] = []
    @IBOutlet var carousel: iCarousel!
    @IBOutlet weak var podTitle: UILabel!

    @IBOutlet weak var invitesButton: UIButton!
    var isPresentingForFirstTime = true
    
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
        carousel.type = .rotary
        carousel.delegate = self
        carousel.dataSource = self
    }
    
    @IBAction func backButton(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func getMyPods(){
        APIClient.sharedInstance.getUserPodIds { (userPods) in
            for pod in userPods {
                if !self.items.contains(where: { $0._podId == pod?._podId }) {
                    if(pod?._geoHash == nil){
                        print("its nil!")
                        return
                    }
                    APIClient.sharedInstance.getPod(withId: pod?._podId as! Int, geoHash: (pod?._geoHash)!, completion: { (podList) in
                        let index = self.items.count
                        self.items.append(podList!)
                        self.getPostsforPod(index: index)
                    })
                }
            }
        }
    }
    
    func getPostsforPod(index: Int){
        let pod = self.items[index]
        APIClient().getPostForPod(withId: (pod._podId as! Int), index: index, completion: { (posts, j) in
            let rev = Array(posts.reversed())
            self.items[j].postData = rev as! [Posts]
            self.carousel.reloadData()
        })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if(segue.identifier == Constants.Storyboard.MySinglePodSegueId){
            if let nextVC = segue.destination as? PodViewController {
                let podView = sender as! PodList
                nextVC.podData = podView
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMyPods()
        APIClient.sharedInstance.getPodRequestsForCurrentUser { (requests) in
            var buttonText = ""
            if(requests.count == 0){
                buttonText = "No Requests"
            } else if requests.count == 1 {
                buttonText = "1 Request"
            } else {
                buttonText = "\(requests.count) Requests"
            }
            self.invitesButton.setTitle(buttonText, for: UIControlState.normal)
        }
    }
    
    @IBAction func returnFromSegueActions(_ sender: UIStoryboardSegue) {
        
    }
    
}

// MARK: - iCarousel Methods

extension MyPodsCarouselViewController: iCarouselDataSource, iCarouselDelegate {
    
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
        self.podTitle.text = self.items[self.carousel.currentItemIndex]._name

        return podView
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        let index = carousel.currentItemIndex
        if(items.isEmpty != true){
            self.podTitle.text = items[index]._name
        }
    }
    
}

// MARK: - PodView Methods

extension MyPodsCarouselViewController: PodViewDelegate {
    func toSinglePod(_ podView: PodList) {
        performSegue(withIdentifier: Constants.Storyboard.MySinglePodSegueId, sender: podView)
    }
}
