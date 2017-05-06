//
//  PodData.swift
//  Pod
//
//  Created by Max Freundlich on 5/6/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class Pod {
    let name: String
    let coordinates: CLLocationCoordinate2D
    let radius: Double
    
    init(name:String, coordinates: CLLocationCoordinate2D, radius: Double) {
        self.name = name
        self.coordinates = coordinates
        self.radius = radius
    }
    
    func getTestData() -> [Pod] {
        var arr = [Pod]();
        var coordinates = CLLocationCoordinate2D(latitude: 37.420487, longitude: -122.171421)
        var p1 = Pod(name: "680 Lomita Pod", coordinates: coordinates, radius: 100)
        arr.append(p1)
        coordinates = CLLocationCoordinate2D(latitude: 37.425076, longitude: -122.170186)
        p1 = Pod(name: "Old Union Pod", coordinates: coordinates, radius: 100)
        arr.append(p1)
        coordinates = CLLocationCoordinate2D(latitude: 37.424305, longitude: -122.170842)
        p1 = Pod(name: "Tressider Pod", coordinates: coordinates, radius: 100)
        arr.append(p1)
        return arr
    }
}

