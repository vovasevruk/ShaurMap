//
//  LocationService.swift
//  ShaurMap
//
//  Created by Vova Seuruk on 2/22/17.
//  Copyright © 2017 Vova Seuruk. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate {
  func tracingLocation(_ currentLocation: CLLocation)
  func tracingLocationDidFailtWith(error: NSError)
}

class LocationService : NSObject, CLLocationManagerDelegate {
  static let sharedInstance: LocationService = {
    let instance = LocationService()
    return instance
  }()
  
  var locationManager: CLLocationManager?
  var currentLocation: CLLocation?
  var delegate: LocationServiceDelegate?
  
  private(set) var isActive = false
  
  override init() {
    super.init()
    
    self.locationManager = CLLocationManager()
    guard let locationManager = self.locationManager else {
      return
    }
    
    if CLLocationManager.authorizationStatus() == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
    }
    
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.distanceFilter = 200
    locationManager.delegate = self
  }
  
  func startUpdatingLocation() {
    print("Starting Location Updates")
    self.locationManager?.startUpdatingLocation()
    isActive = true
  }
  
  func stopUpdatingLocation() {
    print("Stop Location Updates")
    self.locationManager?.stopUpdatingLocation()
    isActive = false
  }
  
  //MARK: CLLocationManagerDelegate
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else {
      return
    }
    
    currentLocation = location
    
    updateLocation(location)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    updateLocationDidFailWithError(error as NSError)
  }
  
  //MARK: Private functions
  fileprivate func updateLocation(_ currentLocation: CLLocation) {
    guard let delegate = self.delegate else {
      return
    }
    
    delegate.tracingLocation(currentLocation)
  }
  
  fileprivate func updateLocationDidFailWithError(_ error: NSError) {
    guard let delegate = self.delegate else {
      return
    }
    
    delegate.tracingLocationDidFailtWith(error: error)
  }
}
