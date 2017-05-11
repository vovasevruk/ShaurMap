//
//  NearMeViewController.swift
//  ShaurMap
//
//  Created by Vova Seuruk on 3/1/17.
//  Copyright © 2017 Vova Seuruk. All rights reserved.
//

import UIKit
import GoogleMaps
import SWRevealViewController

class NearMeViewController: UIViewController {
  @IBOutlet weak var menuButton: UIBarButtonItem!
  
  var findRoute: UIButton!
  var googleMaps : UIButton!
  var userLocation : CLLocation!
  private var restaurants: [Restaurant]?
  private var mapTasks: MapTasks!
  var selectedMarker: GMSMarker?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createButtons()
    
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
  
  private func loadMarkers() {
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
  
  //MARK: Load MapView
  override func loadView() {
    let camera = GMSCameraPosition.camera(withTarget: (LocationService.sharedInstance.currentLocation?.coordinate)!, zoom: 13)
    let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
    mapView.settings.myLocationButton = true
    mapView.isMyLocationEnabled = true
    view = mapView
  }
  

  //MARK: Buttons and actions
  private func createButtons() {
    createGoogleMapsButton()
    createFindRouteButton()
  }
  
  private func createFindRouteButton() {
    findRoute = UIButton(frame: CGRect(x: 80, y: 600, width: 200, height: 60))
    findRoute.addTarget(self, action: #selector(createRoute), for: .touchUpInside)
    findRoute.layer.cornerRadius = 10
    findRoute.backgroundColor = UIColor.darkGray
    findRoute.alpha = CGFloat(0.9)
    findRoute.setTitle("Построить маршрут", for: .normal)
    findRoute.isEnabled = false
    self.view.addSubview(findRoute)
  }
  
  private func createGoogleMapsButton() {
    googleMaps = UIButton(frame: CGRect(x: 5, y: 580, width: 64, height: 64))
    googleMaps.setImage(UIImage(named: "googleMaps"), for: .normal)
    googleMaps.addTarget(self, action: #selector(openGoogleMapsApp), for: .touchUpInside)
    googleMaps.isEnabled = false
    self.view.addSubview(googleMaps)
  }
  
  @objc private func openGoogleMapsApp() {
    if selectedMarker == nil { selectedMarker = (view as! GMSMapView).selectedMarker! }
    let latitude = (selectedMarker!.userData as! Restaurant).adress.coordinate.latitude
    let longitude = (selectedMarker!.userData as! Restaurant).adress.coordinate.longitude
    if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
      UIApplication.shared.open(URL(string:"comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving")!, options: [:], completionHandler: nil)
    } else {
      UIApplication.shared.open(URL(string: "https://maps.google.com/?q=@\(latitude),\(longitude)")!, options: [:], completionHandler: nil)
    }
  }
  
  private var findRouteTapped = false
  
  @objc private func createRoute() {
    findRouteTapped = !findRouteTapped
    findRoute.setTitle((findRouteTapped ? "Отмена" : "Построить маршрут"), for: .normal)
    
    if !findRouteTapped {
      let mapView = self.view as! GMSMapView
      findRoute.isEnabled = (selectedMarker == mapView.selectedMarker ? false : true)
      googleMaps.isEnabled = (selectedMarker == mapView.selectedMarker ? false : true)
      deleteOldRouteAndClearMarker()
    } else {
      selectedMarker = (view as! GMSMapView).selectedMarker!
      let destination = (selectedMarker!.userData as! Restaurant).adress.coordinate
      mapTasks.getDirections(origin: userLocation.coordinate, destination: destination,
                                  waypoints: nil, travelMode: nil, completionHandler: { (status, success) -> Void in
        if success {
          self.mapTasks.routePolyline?.map = nil
          self.selectedMarker!.icon = GMSMarker.markerImage(with: .red)
          self.drawRoute()
          self.displayRouteInfo()
        } else { print(status) }
      })
    }
  }
  
  private func drawRoute() {
    let route = self.mapTasks.overviewPolyline["points" as NSObject] as! String
    let path: GMSPath = GMSPath(fromEncodedPath: route)!
    mapTasks.routePolyline = GMSPolyline(path: path)
    mapTasks.routePolyline?.map = (view as! GMSMapView)
  }
  
  private func displayRouteInfo() {
    print("\(self.mapTasks.totalDistance) \n \(self.mapTasks.totalDuration)")
  }
  
  func deleteOldRouteAndClearMarker() {
    if selectedMarker == (self.view as! GMSMapView).selectedMarker {
      (self.view as! GMSMapView).selectedMarker = nil
    }
    selectedMarker?.icon = GMSMarker.markerImage(with: .black)
    selectedMarker = nil
    self.mapTasks.routePolyline?.map = nil
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
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "Restaurant Info" {
      let destinationVC = segue.destination as! RestaurantViewController
      destinationVC.restaurant = (self.view as! GMSMapView).selectedMarker?.userData as! Restaurant
    }
  }
}


//MARK: GMSMapViewDelegate
extension NearMeViewController: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    findRoute.isEnabled = true
    googleMaps.isEnabled = true
    return false
  }
  
  func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
    performSegue(withIdentifier: "Restaurant Info", sender: self)
  }
}


//MARK:LocationServiceDelegate
extension NearMeViewController: LocationServiceDelegate {
  func tracingLocation(_ currentLocation: CLLocation) {
    userLocation = currentLocation
  }
  
  func tracingLocationDidFailtWith(error: NSError) {
    print(error)
  }
}
