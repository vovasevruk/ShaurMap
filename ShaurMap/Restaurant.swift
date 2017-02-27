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
    
//    init(name: String, latitude: Double, longitude: Double, adressString: String, opensAt: Int, closesAt: Int, mainPicture: UIImage) {
//        self.name = name
//        self.adressString = adressString
//        self.openHour = opensAt
//        self.closeHour = closesAt
//        self.mainPicture = mainPicture
//        self.smallPicture = self.mainPicture
//        self.adress = CLLocation(latitude: latitude, longitude: longitude)
//        self.smallPicture = resizeImage(image: mainPicture)!
//    }
    
    init(name: String, latitude: Double, longitude: Double, adressString: String, opensAt: Int, closesAt: Int, mainPictureURL: String, smallPicture: String) {
        self.name = name
        self.adressString = adressString
        self.openHour = opensAt
        self.closeHour = closesAt
        self.adress = CLLocation(latitude: latitude, longitude: longitude)
        self.mainPicture = URL(string: mainPictureURL)!
        self.smallPicture = URL(string: smallPicture)!
    }
    
    private func resizeImage(image: UIImage) -> UIImage? {
        let newSize = 90
        UIGraphicsBeginImageContext(CGSize(width: newSize, height: newSize))
        image.draw(in: CGRect(x: 0, y: 0, width: newSize, height: newSize))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
