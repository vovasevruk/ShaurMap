//
//  RestaurantBuilder.swift
//
//
//  Created by Vova Seuruk on 2/27/17.
//
//

import Foundation

class RestaurantBuilder {
  static func restaurantsFromJSON(with objectNotation: NSArray) -> [Restaurant] {
    var restaurants = [Restaurant]()
    for (_, value) in objectNotation.enumerated() {
      let restaurantJSON = value as! NSDictionary
      let adressString =  restaurantJSON["adressString"] as! String
      let name = restaurantJSON["name"] as! String
      let closesAt = restaurantJSON["closesAt"] as! String
      let opensAt = restaurantJSON["opensAt"] as! String
      let mainPictureURL = restaurantJSON["mainPictureURL"] as! String
      let latitude = restaurantJSON["latitude"] as! String
      let longitude = restaurantJSON["longitude"] as! String
      let smallPictureURL = restaurantJSON["smallPictureURL"] as! String
      var menu : [String : String]?
      if let _ = restaurantJSON.object(forKey: "menu") {
        menu = (restaurantJSON["menu"] as! [String : String])
      }
      
      let restaurant = Restaurant(name: name, latitude: Double(latitude)!, longitude: Double(longitude)!, adressString: adressString, opensAt: Int(opensAt)!, closesAt: Int(closesAt)!, mainPictureURL: mainPictureURL, smallPicture: smallPictureURL, menu: menu)
      restaurants.append(restaurant)
    }
    print("appended")
    return restaurants
  }
  
  
}
