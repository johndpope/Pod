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
    fileprivate var loadedPods = [NSNumber]()
    fileprivate var expanding = false

    // MARK: - PodMapViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup navigation
        navigationController?.navigationBar.barTintColor = .lightBlue
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
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
    
    // MARK: - Navigation
    
    func closePodMapView() {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? PodViewController,
            let podData = sender as? PodList {
            print(podData.postData)
            destinationVC.podData = podData
        }
    }
}

// MARK: - GMSMapViewDelegate

extension PodMapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        let visibleRegion = mapView.projection.visibleRegion()
        let nearLeft = visibleRegion.nearLeft
        let farRight = visibleRegion.farRight
        
        APIClient.sharedInstance.getNearbyMapPods(location: position.target, expanding: expanding) { (podList, boundaries) in
            guard let podList = podList,
            let boundaries = boundaries else {
                print("Error getting nearby map pods")
                return
            }
            
            for pod in podList {
                if !self.loadedPods.contains(pod._podId!) {
                    self.loadedPods.append(pod._podId!)
                    
                    DispatchQueue.main.async {
                        let infoMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: CLLocationDegrees(pod._latitude!), longitude: CLLocationDegrees(pod._longitude!)))
                        infoMarker.title = pod._name!
                        infoMarker.opacity = 1.0
                        infoMarker.userData = pod
                        infoMarker.map = mapView
                    }
                }
            }
            
            

            if boundaries.west! > nearLeft.longitude || boundaries.east! < farRight.longitude || boundaries.north! < farRight.latitude || boundaries.south! > nearLeft.latitude {
                DispatchQueue.main.async {
                    self.expanding = true
                    self.mapView(mapView, idleAt: position)
                }
            } else {
                self.expanding = false
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard let pod = marker.userData as? PodList else {
            print("Marker user data wasn't a PodList")
            return
        }
        
        APIClient.sharedInstance.getPod(withId: pod._podId as! Int, geoHash: pod._geoHashCode!) { (fullPod) in
            guard let fullPod = fullPod else {
                print("Unable to retrieve full info for pod with id \(pod._podId!)")
                return
            }
            
            APIClient.sharedInstance.getPostForPod(withId: pod._podId as! Int, index: 0, completion: { (posts, j) in
                pod.postData = posts as! [Posts]
                self.performSegue(withIdentifier: "toMapPod", sender: fullPod)
            })
            
        }
    }

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
