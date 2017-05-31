//
//  PodViewSegueUnwind.swift
//  Pod
//
//  Created by Michael-Anthony Doshi on 5/30/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class PodViewSegueUnwind: UIStoryboardSegue {

    // MARK: - Properties
    
//    let podView: PodView?
//    let newPodViewFrame: CGRect?
    
    // MARK: - PodViewSegue
    
    override func perform() {
        source.dismiss(animated: true, completion: nil)
    }
    
//    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
//        if let podCarouselVC = destination as? PodCarouselViewController,
//            let podView = podCarouselVC.carousel.currentItemView as? PodView {
//            self.podView = podView
//            self.newPodViewFrame = podCarouselVC.view.convert(podView.frame, from: podView)
//        } else {
//            self.podView = nil
//            self.newPodViewFrame = nil
//        }
//        super.init(identifier: identifier, source: source, destination: destination)
//    }
//    
//    override func perform() {
//        let screenWidth = UIScreen.main.bounds.size.width
//        let screenHeight = UIScreen.main.bounds.size.height
//        
//        if let podVC = destination as? PodViewController,
//            let podView = self.podView,
//            let oldPodViewFrame = self.newPodViewFrame {
//            let topMargin = podVC.titleTopMargin + podVC.titleBottomMargin + 29.0 // Size of title label
//            
//            UIView.animate(withDuration: 0.3, animations: {
//                podView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - topMargin)
//                podView.transform = CGAffineTransform(translationX: -oldPodViewFrame.minX, y: topMargin - oldPodViewFrame.minY)
//            }, completion: { (completed) in
//                self.source.present(self.destination, animated: false) {
//                    podView.frame = CGRect(x: 0, y: 0, width: oldPodViewFrame.size.width, height: oldPodViewFrame.size.height)
//                }
//            })
//        }
//    }
}
