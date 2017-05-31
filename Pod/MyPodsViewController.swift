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
    @IBOutlet weak var invitesLabel: UILabel!

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
    func getAllPods(){
        let client = APIClient()
        let location = CLLocationCoordinate2D(latitude: 37.4204870, longitude: -122.1714210)
        client.getNearbyPods(location: location) { (pods) in
            for pod in pods! {
                //APIClient().uploadTestPostsToPod(withId: pod.podID)
                if !self.items.contains(where: { $0._podId == pod._podId }) {
                    self.items.append(pod)
                }
            }
            print(self.items)
            self.getLimitedPostsForPods()
        }
    }
    
    func getMyPods(){
        APIClient.sharedInstance.getUserPodIds { (userPods) in
            for pod in userPods {
                APIClient.sharedInstance.getPod(withId: pod?._podId as! Int, geoHash: (pod?._geoHash)!, completion: { (podList) in
                    //self.items.append(podList)
                })
            }
        }
    }
    
    func getLimitedPostsForPods(){
        for i in 0..<self.items.count{
            let pod = self.items[i]
            APIClient().getPostForPod(withId: (pod._podId as! Int), index: i, completion: { (posts, j) in
                if(j != -1){
                    self.items[j].postData = posts as! [Posts]
                    self.carousel.reloadData()
                }
            })
        }
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
        getAllPods()
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