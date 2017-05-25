//
//  UIView+Autolayout.swift
//  Pod
//
//  Created by Michael-Anthony Doshi on 5/6/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import Foundation

extension UIView {
    
    func usingAutolayout() -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
    
}
