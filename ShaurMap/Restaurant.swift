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
  let name : String
  let adress : CLLocation
  let adressString : String
  let openHour : Int
  let closeHour : Int
  let mainPicture : URL
  var smallPicture : URL
  var menu : [String:Double]
  
  init(name: String, latitude: Double, longitude: Double, adressString: String, opensAt: Int, closesAt: Int, mainPictureURL: String, smallPicture: String, menu : [String:String]?) {
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
  }
  
  static let labels : [String: String] = [
    "mini" : "Мини",
    "standard" : "Стандартная",
    "big" : "Большая",
    "mini-king" : "Королевская мини",
    "king" : "Королевская"
  ]
  
  private func resizeImage(image: UIImage) -> UIImage? {
    let newSize = 90
    UIGraphicsBeginImageContext(CGSize(width: newSize, height: newSize))
    image.draw(in: CGRect(x: 0, y: 0, width: newSize, height: newSize))
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
}
