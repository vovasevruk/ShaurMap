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
  
  var findRoute: UIButton!
  var userLocation : CLLocation!
  var restaurants: [Restaurant]?
  var mapTasks: MapTasks!
  var selectedMarker: GMSMarker?
  var lastSelectedMarker: GMSMarker?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createFindRouteButton()
    
    (view as! GMSMapView!).delegate = self
    mapTasks = MapTasks()
    
    if let restaurantList = Shared.sharedInstance.restaurants { restaurants = restaurantList }
    loadMarkers()
    
    if !Shared.sharedInstance.allRestaurantsAreFetched { Shared.loadAllRestaurants() }
    
    if self.revealViewController() != nil {
      menuButton.target = self.revealViewController()
      menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
      self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    LocationService.sharedInstance.delegate = self
    userLocation = LocationService.sharedInstance.currentLocation
    
    NotificationCenter.default.addObserver(self, selector: #selector(getUpdatedRestaurants),
          name: Notification.Name(rawValue: Shared.sharedInstance.restaurantsDidUpdateNotification), object: nil)
  }
  
  func deleteOldRouteAndClearMarker() {
    lastSelectedMarker?.icon = GMSMarker.markerImage(with: .black)
    lastSelectedMarker = nil
  }
  
  func drawRoute() {
    let route = self.mapTasks.overviewPolyline["points" as NSObject] as! String
    
    let path: GMSPath = GMSPath(fromEncodedPath: route)!
    mapTasks.routePolyline = GMSPolyline(path: path)
    mapTasks.routePolyline?.map = (view as! GMSMapView)
  }
  
  func displayRouteInfo() {
    print("\(self.mapTasks.totalDistance) \n \(self.mapTasks.totalDuration)")
  }
  
  func createFindRouteButton() {
    findRoute = UIButton(frame: CGRect(x: 80, y: 600, width: 200, height: 60))
    findRoute.addTarget(self, action: #selector(createRoute), for: UIControlEvents.allEvents)
    findRoute.layer.cornerRadius = 10
    findRoute.backgroundColor = UIColor.gray
    findRoute.alpha = CGFloat(0.7)
    findRoute.setTitle("Построить маршрут", for: .normal)
    findRoute.isEnabled = false
    self.view.addSubview(findRoute)
  }
  
  func createRoute() {
//    if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
//      UIApplication.shared.open(URL(string:"comgooglemaps://?saddr=&daddr=\((selectedMarker?.userData as! Restaurant).adress.coordinate.latitude),\((selectedMarker?.userData as! Restaurant).adress.coordinate.longitude)&directionsmode=driving")!, options: [:], completionHandler: nil)
//    } else {
//      let latitude = (selectedMarker?.userData as! Restaurant).adress.coordinate.latitude
//      let longitude = (selectedMarker?.userData as! Restaurant).adress.coordinate.longitude
//      //UIApplication.shared.open(URL(string:"https://www.google.com/maps/dir/@\(latitude),\(longitude),17z/data=!4m3!1m2!3m1!2zNTPCsDU1JzE3LjYiTiAyN8KwMzQnNDUuMCJF")!, options: [:], completionHandler: nil)
//      UIApplication.shared.open(URL(string: "https://maps.google.com/?q=@\(latitude),\(longitude)")!, options: [:], completionHandler: nil)
//    }
    
    if self.mapTasks.routePolyline != nil {
      deleteOldRouteAndClearMarker()
    }
    
    let destination = (selectedMarker!.userData as! Restaurant).adress.coordinate
    mapTasks.getDirections(origin: userLocation.coordinate, destination: destination,
                                waypoints: nil, travelMode: nil, completionHandler: { (status, success) -> Void in
      if success {
        self.mapTasks.routePolyline?.map = nil
        self.selectedMarker!.icon = GMSMarker.markerImage(with: .red)
        self.lastSelectedMarker = self.selectedMarker!
        self.drawRoute()
        self.displayRouteInfo()
      } else { print(status) }
    })
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
        marker.userData = restaurant
        marker.snippet = restaurant.adressString
        marker.icon = GMSMarker.markerImage(with: .black)
        marker.map = view as! GMSMapView!
      }
    }
  }
}

extension NearMeViewController: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    selectedMarker = marker
    findRoute.isEnabled = true
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
