//
//  ViewController.swift
//  Bergjes2018
//
//  Created by Hugo Trippaers on 29/04/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController {
    var locationManager = CLLocationManager()
    var gameManager = GameManager.shared
    var gameTimer: Timer!;
    var position: CLLocation?;
    
    var mapMarkers: [GMSMarker] = [];
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBAction func openBackpack(_ sender: Any) {
        let backbackViewController = storyboard?.instantiateViewController(withIdentifier: "RugzakView") as! RugzakViewController
        backbackViewController.gameManager = self.gameManager
        self.present(backbackViewController, animated: true)

    }
    
    @IBAction func clickManagement(_ sender: Any) {
        showManagementPasswordDialog()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Start requesting location updates
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.gameManager.delegate = self

        let start: GameLocation = self.gameManager.retrieveLocationsDatabase()["start"]!
        
        let camera = GMSCameraPosition.camera(withLatitude: start.latitude, longitude: start.longitude, zoom: 16.2348)
        mapView.camera = camera
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.mapType = .hybrid
        
        gameTimer = Timer.scheduledTimer(timeInterval: 5, target: self,
                                         selector: #selector(updateLocationState), userInfo: nil, repeats: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateLocationState() {
        if (position != nil) {
            let currentLocation = GameLocation(name: "player", latitude: position!.coordinate.latitude, longitude: position!.coordinate.longitude)
            gameManager.updateCurrentLocation(playerPosition: currentLocation)
        }
    }
    
    func showManagementPasswordDialog() {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Beheer", message: "Enter passcode", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            //getting the input values from user
            let password = alertController.textFields?[0].text
            
            if (password == "1294") {
                self.showManagementViewController()
            } else {
                NSLog("Wrong password")
            }
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = "Enter Passcode"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showManagementViewController() {
        let managementViewController = storyboard?.instantiateViewController(withIdentifier: "ManagementView") as! ManagementViewController
        managementViewController.gameManager = self.gameManager
        self.present(managementViewController, animated: true)

    }
    
    func showLocationDetails(location: GameLocation) {
        self.definesPresentationContext = true
        self.providesPresentationContextTransitionStyle = true
        self.overlayBlurredBackgroundView()
        
        let itemViewController = storyboard?.instantiateViewController(withIdentifier: "RugzakItemView") as! RugzakItemViewController
        itemViewController.delegate = self
        itemViewController.modalPresentationStyle = .overFullScreen
        
        itemViewController.location = location
        itemViewController.itemText = gameManager.getDescriptionForLocation(location: location)
        
        self.present(itemViewController, animated: true)
    }

}

extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        NSLog("Lat %03.6f, Lon %03.6f, Zoom %03.6f",
              position.target.latitude, position.target.longitude, position.zoom)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let locationId = marker.title {
            if let location = gameManager.locations[locationId] {
                if (gameManager.isCurrentLocation(location: location)) {
                    showLocationDetails(location: location)
                } else {
                    return false
                }
                
            }
        }
        return true
    }
}

extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (!locations.isEmpty) {
            NSLog("didUpdateLocations called with lat \(locations[0].coordinate.latitude), lon \(locations[0].coordinate.longitude), acc \(locations[0].horizontalAccuracy)")
            position = locations[0]
        }
    }

}

extension ViewController: GameManagerDelegate {

    func updateVisibleLocations(locations: [GameLocation]) {
        // Clear current markers
        for marker in mapMarkers {
            marker.map = nil
        }
        mapMarkers = []
        
        for location in locations {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            marker.title = location.name
            
            if (location.imageReference != nil) {
                marker.icon = Utility.resizeImage(image: UIImage(named: location.imageReference!)!,
                                          targetSize: CGSize(width: 50.0, height: 50.0))
            } else {
                marker.icon = GMSMarker.markerImage(with: gameManager.getColorForLocation(location: location))
            }
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            marker.map = mapView

            mapMarkers.append(marker)
        }
    }
}

extension ViewController: RugzakItemViewControllerDelegate {
    func overlayBlurredBackgroundView() {
        let blurredBackgroundView = UIVisualEffectView()
        
        
        blurredBackgroundView.frame = view.frame
        blurredBackgroundView.effect = UIBlurEffect(style: .dark)
        
        view.addSubview(blurredBackgroundView)
    }
    
    func removeBlurredBackgroundView() {
        
        for subview in view.subviews {
            if subview.isKind(of: UIVisualEffectView.self) {
                subview.removeFromSuperview()
            }
        }
    }

}
