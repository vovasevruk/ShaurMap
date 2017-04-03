//
//  MapTasks.swift
//  ShaurMap
//
//  Created by Vova Seuruk on 3/3/17.
//  Copyright © 2017 Vova Seuruk. All rights reserved.
//

import Foundation
import GoogleMaps

class MapTasks {
  let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
  
  var selectedRoute: Dictionary<NSObject, AnyObject>!
  var overviewPolyline: Dictionary<NSObject, AnyObject>!
  
  //distance
  var totalDistanceInMeters: UInt = 0
  var totalDistance: String!
  var totalDurationInSeconds: UInt = 0
  var totalDuration: String!
  
  var routePolyline: GMSPolyline?
  
  enum TravelModes: Int {
    case driving
    case walking
    case bicycling
  }
  
  func getDirections(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, waypoints: Array<String>!,
                     travelMode: TravelModes?, completionHandler: @escaping ((_ status: String, _ success: Bool) -> Void)) {
    let firstPart = baseURLDirections + "origin=" + String(origin.latitude as Double)
    let secondPart = "," + String(origin.longitude as Double)
    let thirdPart = "&destination=" + String(destination.latitude as Double) + "," + String(destination.longitude as Double) + "&key=" + "AIzaSyA8QPyKwgOS0EqdlF3opeLnikIj3LQnqoI"
    var directionsURLString =  firstPart + secondPart + thirdPart
    if let travel = travelMode {
      var travelModeString = ""
      
      switch travel.rawValue {
      case TravelModes.walking.rawValue:
        travelModeString = "walking"
      case TravelModes.bicycling.rawValue:
        travelModeString = "bicycling"
      default:
        travelModeString = "driving"
      }
      directionsURLString += "&mode=" + travelModeString
    }
    let directionsURL = NSURL(string: directionsURLString)
    
    DispatchQueue.global().async {
      let directionsData = try? Data(contentsOf: directionsURL! as URL)
      DispatchQueue.main.async {
        let dictionary: Dictionary<NSObject, AnyObject> = try! JSONSerialization.jsonObject(with: directionsData!, options: .mutableContainers) as! Dictionary<NSObject, AnyObject>
        
        let status = dictionary["status" as NSObject] as! String
        
        if status == "OK" {
          self.selectedRoute = (dictionary["routes" as NSObject] as! Array<Dictionary<NSObject, AnyObject>>)[0]
          self.overviewPolyline = self.selectedRoute["overview_polyline" as NSObject] as! Dictionary<NSObject, AnyObject>
          
          self.calculateTotalDistanceAndDuration()
          
          completionHandler(status, true)
        }
        else {
          completionHandler(status, false)
        }
      }
    }
  }
  
  func calculateTotalDistanceAndDuration() {
    let legs = self.selectedRoute["legs" as NSObject] as! Array<Dictionary<NSObject, AnyObject>>
    
    totalDistanceInMeters = 0
    totalDurationInSeconds = 0
    
    for leg in legs {
      totalDistanceInMeters += (leg["distance" as NSObject] as! Dictionary<NSObject, AnyObject>)["value" as NSObject] as! UInt
      totalDurationInSeconds += (leg["duration" as NSObject] as! Dictionary<NSObject, AnyObject>)["value" as NSObject] as! UInt
    }
    
    let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
    totalDistance = "\n\nTotal Distance: \(distanceInKilometers) Km"
    
    let mins = totalDurationInSeconds / 60
    let hours = mins / 60
    let remainingMins = mins % 60
    let remainingSecs = totalDurationInSeconds % 60
    
    totalDuration = "Duration: \(hours) h, \(remainingMins) mins, \(remainingSecs) secs"
  }
  
}
