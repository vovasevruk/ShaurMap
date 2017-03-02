//
//  NearMeViewController.swift
//  ShaurMap
//
//  Created by Vova Seuruk on 3/1/17.
//  Copyright © 2017 Vova Seuruk. All rights reserved.
//

import UIKit
import GoogleMaps

class NearMeViewController: UIViewController {
  @IBOutlet weak var menuButton: UIBarButtonItem!
  
  var userLocation : CLLocation!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if self.revealViewController() != nil {
      menuButton.target = self.revealViewController()
      menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
      self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    LocationService.sharedInstance.delegate = self
    userLocation = LocationService.sharedInstance.currentLocation
    
    loadMarkers()
  }
  
  override func loadView() {
    let camera = GMSCameraPosition.camera(withTarget: (LocationService.sharedInstance.currentLocation?.coordinate)!, zoom: 13)
    let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
    mapView.settings.myLocationButton = true
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    mapView.isMyLocationEnabled = true
    
    view = mapView
  }
  
  func loadMarkers() {
    if let restaurants = Shared.sharedInstance.restaurants {
      for restaurant in restaurants {
        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: restaurant.adress.coordinate.latitude, longitude: restaurant.adress.coordinate.longitude))
        marker.title = restaurant.name
        marker.snippet = restaurant.adressString
        marker.map = view as! GMSMapView!
      }
    }
  }
}

extension NearMeViewController : LocationServiceDelegate {
  func tracingLocation(_ currentLocation: CLLocation) {
    userLocation = currentLocation
  }
  
  func tracingLocationDidFailtWith(error: NSError) {
    print(error)
  }
}
