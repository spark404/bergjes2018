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
        //let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.camera = camera
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.mapType = .hybrid
        
        gameTimer = Timer.scheduledTimer(timeInterval: 5, target: self,
                                         selector: #selector(updateLocationState), userInfo: nil, repeats: true)
        
//        for (name, location) in self.gameManager.retrieveLocationsDatabase() {
//            // Creates a marker in the center of the map.
//            let marker = GMSMarker()
//            marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
//            marker.title = name
//            // marker.snippet = "Veel plezier..."
//            marker.map = mapView
//
//            monitorRegionAtLocation(location: location)
//        }
        
        for (region) in locationManager.monitoredRegions {
            NSLog("Monitoring region \(region.identifier): entry \(region.notifyOnEntry), exit \(region.notifyOnExit)")
            let clRegion: CLCircularRegion = region as! CLCircularRegion
            NSLog("  lat: \(clRegion.center.latitude) lon: \(clRegion.center.longitude) radius \(clRegion.radius)");
            self.locationManager.requestState(for: region)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func monitorRegionAtLocation(location: GameLocation ) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                let maxDistance = 5.0
                let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                let identifier = location.name
                
                let region = CLCircularRegion(center: center,
                                              radius: maxDistance, identifier: identifier)
                region.notifyOnEntry = true
                region.notifyOnExit = true
                
                locationManager.startMonitoring(for: region)
            } else {
                NSLog("Region monitoring is not available")
            }
        } else {
            NSLog("Location authorization state isn't helpful")
        }
        
    }
    
    @objc func updateLocationState() {
        if (position != nil) {
            let currentLocation = GameLocation(name: "player", latitude: position!.coordinate.latitude, longitude: position!.coordinate.longitude)
            gameManager.updateCurrentLocation(playerPosition: currentLocation)
        }
    }
    
}

extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        NSLog("Lat %03.6f, Lon %03.6f, Zoom %03.6f",
              position.target.latitude, position.target.longitude, position.zoom)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        NSLog("Entered region \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        NSLog("Left region \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (!locations.isEmpty) {
            NSLog("didUpdateLocations called with lat \(locations[0].coordinate.latitude), lon \(locations[0].coordinate.longitude), acc \(locations[0].horizontalAccuracy)")
            position = locations[0]
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        NSLog("Determined state for \(region.identifier) : \(state.rawValue)")
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
