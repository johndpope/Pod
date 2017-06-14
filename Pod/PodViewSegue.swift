//
//  PodViewSegue.swift
//  Pod
//
//  Created by Michael-Anthony Doshi on 5/30/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class PodViewSegue: UIStoryboardSegue {
    
    // MARK: - Properties
    
    let podView: PodView?
    let oldPodViewFrame: CGRect?

    // MARK: - PodViewSegue
    
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        if let podCarouselVC = source as? PodCarouselViewController,
            let podView = podCarouselVC.carousel.currentItemView as? PodView {
            self.podView = podView
            self.oldPodViewFrame = podCarouselVC.view.convert(podView.frame, from: podView)
        } else if let podCarouselVC = source as? MyPodsCarouselViewController,
            let podView = podCarouselVC.carousel.currentItemView as? PodView {
            self.podView = podView
            self.oldPodViewFrame = podCarouselVC.view.convert(podView.frame, from: podView)
        } else {
            self.podView = nil
            self.oldPodViewFrame = nil
        }
        super.init(identifier: identifier, source: source, destination: destination)
    }
    
    override func perform() {
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        if let podVC = destination as? PodViewController,
            let podView = self.podView,
            let oldPodViewFrame = self.oldPodViewFrame {
            let topMargin = podVC.titleTopMargin + podVC.titleBottomMargin + 29.0 // Size of title label
            
            UIView.animate(withDuration: 0.3, animations: {
                podView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - topMargin)
                podView.transform = CGAffineTransform(translationX: -oldPodViewFrame.minX, y: topMargin - oldPodViewFrame.minY)
                podView.addCornerRadiusAnimation(from: 26.0, to: 0, duration: 0.3)
            }, completion: { (completed) in
                self.source.present(self.destination, animated: false) {
                    podView.frame = CGRect(x: 0, y: 0, width: oldPodViewFrame.size.width, height: oldPodViewFrame.size.height)
                    podView.layer.cornerRadius = 26.0
                }
            })
        }
    }
}
