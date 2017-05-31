//
//  PodViewSegueUnwind.swift
//  Pod
//
//  Created by Michael-Anthony Doshi on 5/30/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit

class PodViewSegueUnwind: UIStoryboardSegue {

    override func perform() {
        let secondVCView = self.source.view!
        let firstVCView = self.destination.view!
        
        let screenHeight = UIScreen.main.bounds.size.height
        
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(firstVCView, aboveSubview: secondVCView)
        
        // Animate the transition.
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            firstVCView.frame = firstVCView.frame.offsetBy(dx: 0.0, dy: screenHeight)
            secondVCView.frame = secondVCView.frame.offsetBy(dx: 0.0, dy: screenHeight)
            
        }) { (Finished) -> Void in
            
            self.source.dismiss(animated: false, completion: nil)
        }
    }
}
