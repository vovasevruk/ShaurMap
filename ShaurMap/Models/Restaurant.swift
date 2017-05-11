//
//  Restaurant.swift
//  ShaurMap
//
//  Created by Vova Seuruk on 2/22/17.
//  Copyright © 2017 Vova Seuruk. All rights reserved.
//

import Foundation
import CoreLocation

class Restaurant {
  let name: String
  let id: Int
  let adress: CLLocation
  let adressString: String
  let openHour: Int
  let closeHour: Int
  let mainPicture: URL
  let smallPicture: URL
  let menu: [String:Double]
  var rating: Double
  var voted: Int
  
  
  init(name: String, id: Int, latitude: Double, longitude: Double, adressString: String, opensAt: Int, closesAt: Int, mainPictureURL: String, smallPicture: String, menu : [String:String]?, rating: Double, voted: Int) {
    self.name = name
    self.adressString = adressString
    self.openHour = opensAt
    self.closeHour = closesAt
    self.adress = CLLocation(latitude: latitude, longitude: longitude)
    self.mainPicture = URL(string: mainPictureURL)!
    self.smallPicture = URL(string: smallPicture)!
    var _menu = [String:Double]()
    for label in Restaurant.labels.keys {
      if let key = menu?[label] {
        _menu[Restaurant.labels[label]!] = Double(key)
      }
    }
    self.menu = _menu
    self.rating = rating
    self.voted = voted
    self.id = id
  }
  
  static let labels : [String: String] = [
    "mini" : "Мини",
    "standard" : "Стандартная",
    "big" : "Большая",
    "mini-king" : "Королевская мини",
    "king" : "Королевская"
  ]
}
