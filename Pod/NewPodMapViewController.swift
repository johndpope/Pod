//
//  NewPodMapViewController.swift
//  Pod
//
//  Created by Michael-Anthony Doshi on 5/28/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit
import GoogleMaps

class NewPodMapViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate lazy var mapView: GMSMapView = {
        
        // Default location to CS 377U classroom
        let camera = GMSCameraPosition.camera(withLatitude: 37.43, longitude: -122.17, zoom: 17.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
//        mapView.settings.myLocationButton = true
//        mapView.settings.scrollGestures = false
        mapView.settings.setAllGesturesEnabled(false)
//        mapView.settings.rotateGestures = false
//        mapView.settings.tiltGestures = false
        mapView.setMinZoom(11.709, maxZoom: mapView.maxZoom)
        return mapView
    }()
    
    fileprivate lazy var podRadiusView: OverlayView = {
        let podRadiusView = OverlayView()
        podRadiusView.backgroundColor = .lightBlueTint
        podRadiusView.layer.borderColor = UIColor.lightBlueBorder.cgColor
        podRadiusView.layer.borderWidth = 5.0
        podRadiusView.clipsToBounds = true
        return podRadiusView
    }()
    
    fileprivate lazy var podRadiusSlider: UISlider = {
        let podRadiusSlider = UISlider()
        podRadiusSlider.backgroundColor = .lightBlue
        podRadiusSlider.minimumValue = 0
        podRadiusSlider.maximumValue = 100.0
        podRadiusSlider.minimumTrackTintColor = .darkBlue
        podRadiusSlider.maximumTrackTintColor = .white
        podRadiusSlider.isContinuous = true
        podRadiusSlider.value = 50.0
        podRadiusSlider.addTarget(self, action: #selector(updateMapZoom(_:)), for: .valueChanged)
        return podRadiusSlider
    }()
    
    fileprivate var locationManager = CLLocationManager()
    fileprivate var sliderIncrement: Float!
    
    // MARK: - NewPodMapViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup navigation
        navigationController?.navigationBar.barTintColor = .lightBlue
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        title = "Set Pod Radius"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closePodMapView))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continue", style: .plain, target: self, action: #selector(toNamePodView))

        // Setup view
        view.backgroundColor = .lightBlue
        view.addSubview(mapView.usingAutolayout())
        view.addSubview(podRadiusView.usingAutolayout())
        view.addSubview(podRadiusSlider.usingAutolayout())
        setupConstraints()
        
        // Setup slider
        sliderIncrement = (mapView.maxZoom - mapView.minZoom) / 100.0
        podRadiusSlider.value = (mapView.camera.zoom - mapView.minZoom) / sliderIncrement
        
        // Go to current location
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        podRadiusView.layer.cornerRadius = podRadiusView.frame.size.width / 2.0
    }
    
    // MARK: - Helper Methods
    
    private func setupConstraints() {
        
        // Map View
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: podRadiusSlider.topAnchor)
            ])
        
        // Pod Radius View
        NSLayoutConstraint.activate([
            podRadiusView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            podRadiusView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -32.0),
            podRadiusView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 36.0),
            podRadiusView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -36.0),
            podRadiusView.heightAnchor.constraint(equalTo: podRadiusView.widthAnchor)
            ])
        
        // Pod Radius Slider
        NSLayoutConstraint.activate([
            podRadiusSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8.0),
            podRadiusSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8.0),
            podRadiusSlider.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            podRadiusSlider.heightAnchor.constraint(equalToConstant: 64.0)
            ])
    }
    
    fileprivate func calculateDistance(fromLocation startLocation: CLLocationCoordinate2D, toLocation endLocation: CLLocationCoordinate2D) -> Double {
        
        let earthRadius = 6378.137 // Earth radius in km
        
        // Calculate delta lat/long
        let dLat = (endLocation.latitude - startLocation.latitude) * Double.pi / 180
        let dLong = (endLocation.longitude - startLocation.longitude) * Double.pi / 180
        
        // Some crazy math
        let a = sin(dLat / 2) * sin(dLat / 2) + cos(startLocation.latitude * Double.pi / 180) * cos(endLocation.latitude * Double.pi / 180) * sin(dLong / 2) * sin(dLong / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let d = earthRadius * c
        
        return d * 0.621371 // Convert to miles
    }
    
    func updateMapZoom(_ sender: UISlider) {
        let zoom = sender.value * sliderIncrement + mapView.minZoom
        mapView.animate(toZoom: zoom)
    }
    
    // MARK: - Navigation
    
    func closePodMapView() {
        dismiss(animated: true, completion: nil)
    }
    
    func toNamePodView() {
        performSegue(withIdentifier: "toNamePod", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if(segue.identifier == "toNamePod"){
            if let nextVC = segue.destination as? PodTitleViewController {
                let podRadiusPoint = CGPoint(x: podRadiusView.frame.minX, y: podRadiusView.frame.maxY - podRadiusView.frame.size.height / 2.0)
                let podRadiusCoordinate = mapView.projection.coordinate(for: podRadiusPoint)
                let currentLocation = locationManager.location?.coordinate
                let radius = calculateDistance(fromLocation: currentLocation!, toLocation: podRadiusCoordinate)
                
                nextVC.location = currentLocation
                nextVC.radius = min(radius, 3.5)

                print("Pod Radius: \(radius)")
            }
        }
    }
}

// MARK: - GMSMapViewDelegate

extension NewPodMapViewController: GMSMapViewDelegate {
//    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
//        podRadiusSlider.value = (position.zoom - mapView.minZoom) / sliderIncrement
//    }
}

// MARK: - CLLocationManagerDelegate

extension NewPodMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let cameraUpdate = GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!))
        mapView.animate(with: cameraUpdate)
        
        self.locationManager.stopUpdatingLocation()
    }
}
