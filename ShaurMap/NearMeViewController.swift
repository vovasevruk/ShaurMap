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
  var restaurants: [Restaurant]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    (view as! GMSMapView!).delegate = self
    
    if self.revealViewController() != nil {
      menuButton.target = self.revealViewController()
      menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
      self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    LocationService.sharedInstance.delegate = self
    userLocation = LocationService.sharedInstance.currentLocation
    
    loadMarkers()
    
    NotificationCenter.default.addObserver(self, selector: #selector(getUpdatedRestaurants),
                                           name: Notification.Name(rawValue: Shared.sharedInstance.restaurantsDidUpdateNotification), object: nil)
  }
  
  //MARK: Notifications
  @objc private func getUpdatedRestaurants() {
    restaurants = Shared.sharedInstance.restaurants!
    (view as! GMSMapView!).clear()
    loadMarkers()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Shared.sharedInstance.restaurantsDidUpdateNotification), object: nil)
  }

  //MARK: Load MapView
  override func loadView() {
    let camera = GMSCameraPosition.camera(withTarget: (LocationService.sharedInstance.currentLocation?.coordinate)!, zoom: 13)
    let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
    mapView.settings.myLocationButton = true
    mapView.isMyLocationEnabled = true
    view = mapView
  }
  
  func loadMarkers() {
    if let restaurantList = restaurants {
      for restaurant in restaurantList {
        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: restaurant.adress.coordinate.latitude, longitude: restaurant.adress.coordinate.longitude))
        marker.title = restaurant.name
        marker.snippet = restaurant.adressString
        marker.icon = GMSMarker.markerImage(with: .black)
        marker.map = view as! GMSMapView!
      }
    }
  }
}

extension NearMeViewController: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    print(marker.title!)
    return false
  }
}

extension NearMeViewController: LocationServiceDelegate {
  func tracingLocation(_ currentLocation: CLLocation) {
    userLocation = currentLocation
  }
  
  func tracingLocationDidFailtWith(error: NSError) {
    print(error)
  }
}
