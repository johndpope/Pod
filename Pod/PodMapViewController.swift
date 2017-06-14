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
    fileprivate var podMapPreview: PodMapPreview?

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
        
        
        print("Position: \(position.target)")
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
            
            guard let west = boundaries.west,
            let east = boundaries.east,
            let north = boundaries.north,
                let south = boundaries.south else {
                    print("Error in boundaries")
                    self.expanding = false
                    return
            }
            
            if west > nearLeft.longitude || east < farRight.longitude || north < farRight.latitude || south > nearLeft.latitude {
                DispatchQueue.main.async {
                    self.expanding = true
                    self.mapView(mapView, idleAt: position)
                }
            } else {
                self.expanding = false
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if let podMapPreview = self.podMapPreview {
            let frame = view.frame
            let width = frame.width
            UIView.animate(withDuration: 0.3, animations: { 
                podMapPreview.frame = CGRect(x: 0, y: podMapPreview.frame.maxY + 88.5, width: width, height: 66.0)
            }, completion: { (_) in
                podMapPreview.removeFromSuperview()
                self.podMapPreview = nil
            })
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let podData = marker.userData as? PodList {
            let frame = view.frame
            let width = frame.width
            let newPodMapPreview = PodMapPreview(frame: CGRect(x: 0, y: frame.height + 22.5, width: width, height: 66.0), podData: podData)
            newPodMapPreview.delegate = self
            view.addSubview(newPodMapPreview)
            
            if let oldPodMapPreview = self.podMapPreview {
                UIView.animate(withDuration: 0.3, animations: {
                    oldPodMapPreview.frame = CGRect(x: 0, y: oldPodMapPreview.frame.maxY + 88.5, width: width, height: 66.0)
                }, completion: { (_) in
                    oldPodMapPreview.removeFromSuperview()
                    UIView.animate(withDuration: 0.3) {
                        newPodMapPreview.frame = CGRect(x: 0, y: newPodMapPreview.frame.minY - 88.5, width: width, height: 66.0)
                    }
                })
            } else {
                UIView.animate(withDuration: 0.3) {
                    newPodMapPreview.frame = CGRect(x: 0, y: newPodMapPreview.frame.minY - 88.5, width: width, height: 66.0)
                }
            }
            
            self.podMapPreview = newPodMapPreview
            return true
        } else {
            return false
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

// MARK: - PodMapPreviewDelegate

extension PodMapViewController: PodMapPreviewDelegate {
    func openButtonPressed(_ pod: PodList) {
        APIClient.sharedInstance.getPostForPod(withId: pod._podId as! Int, index: 0, completion: { (posts, j) in
            pod.postData = posts as? [Posts]
            self.performSegue(withIdentifier: "toMapPod", sender: pod)
        })
        
        
//        APIClient.sharedInstance.getPod(withId: pod._podId as! Int, geoHash: pod._geoHashCode!) { (fullPod) in
//            guard let fullPod = fullPod else {
//                print("Unable to retrieve full info for pod with id \(pod._podId!)")
//                return
//            }
//            
//            APIClient.sharedInstance.getPostForPod(withId: pod._podId as! Int, index: 0, completion: { (posts, j) in
//                pod.postData = posts as? [Posts]
//                self.performSegue(withIdentifier: "toMapPod", sender: fullPod)
//            })
//            
//        }
    }
}
