//
//  PodMapViewController.swift
//  Pod
//
//  Created by Michael-Anthony Doshi on 5/28/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit
import GoogleMaps

class PodMapViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate lazy var mapView: GMSMapView = {
        
        // Default location to CS 377U classroom
        let camera = GMSCameraPosition.camera(withLatitude: 37.43, longitude: -122.17, zoom: 17.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        return mapView
    }()
    
    fileprivate var locationManager = CLLocationManager()

    // MARK: - PodMapViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup navigation
        title = "Nearby Pods"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closePodMapView))
        
        // Setup mapView
        view.addSubview(mapView.usingAutolayout())
        setupConstraints()
        
        // Go to current location
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Helper Methods
    
    private func setupConstraints() {
        
        // Map View
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    func closePodMapView() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - GMSMapViewDelegate

extension PodMapViewController: GMSMapViewDelegate {
    
}

// MARK: - CLLocationManagerDelegate

extension PodMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let cameraUpdate = GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!))
        mapView.animate(with: cameraUpdate)
        
        self.locationManager.stopUpdatingLocation()
    }
}
