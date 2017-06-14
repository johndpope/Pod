//
//  PodCreationViewController.swift
//  Pod
//
//  Created by Max Freundlich on 5/6/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class PodCreationViewController: UIViewController {

//    @IBOutlet weak var podTitle: UITextField!
//    @IBOutlet weak var podLocation: UITextField!
//    @IBOutlet weak var podRadius: UITextField!
    
   // var location: GMSPlace!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        podLocation.addTarget(self, action: #selector(self.autoComplete(textField:)), for: UIControlEvents.touchDown)
//        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
//        let mapView = GMSMapView.map(withFrame: CGRect(x: 100, y: 270, width: 250 , height: 250) , camera: camera)
//        view.addSubview(mapView)
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
//        marker.map = mapView
    }
    
//    func autoComplete(textField: UITextField) {
//        // user touch field
//        let autocompleteController = GMSAutocompleteViewController()
//        autocompleteController.delegate = self
//        present(autocompleteController, animated: true, completion: nil)
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func createPod(_ sender: Any) {
//        if(allFieldsEntered()){
//            
//        }
//    }
//    
//    func allFieldsEntered() -> Bool {
//        if(podTitle.text == "") {
//            return false;
//        }
//        if(podLocation.text == ""){
//             return false;
//        }
//        if(podRadius.text == "") {
//            return false;
//        }
//        return true
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//extension PodCreationViewController: GMSAutocompleteViewControllerDelegate {
//    
//    // Handle the user's selection.
//    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
//        print("Place name: \(place.name)")
//        print("Place address: \(place.formattedAddress)")
//        print("Place attributions: \(place.attributions)")
//        dismiss(animated: true, completion: nil)
//        podLocation.text = place.name
//        location = place
//    }
//    
//    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
//        // TODO: handle the error.
//        print("Error: ", error.localizedDescription)
//    }
//    
//    // User canceled the operation.
//    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
//        dismiss(animated: true, completion: nil)
//    }
//    
//    // Turn the network activity indicator on and off again.
//    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//    }
//    
//    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//    }
//    
//}
