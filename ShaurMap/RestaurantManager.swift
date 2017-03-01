//
//  RestaurantManager.swift
//  ShaurMap
//
//  Created by Vova Seuruk on 2/27/17.
//  Copyright © 2017 Vova Seuruk. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class RestaurantManager {
    
    var ref =  FIRDatabase.database().reference(withPath: "restaurants")

    var delegate : RestaurantManagerDelegate?
    
    func fetchFirstRestaurants(with amout: Int) {
        ref.queryLimited(toFirst: UInt(amout)).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            self.delegate?.didReceive(restaurants: RestaurantBuilder.restaurantsFromJSON(with: snapshot.value as! NSArray))
        })
    }
    
    func fetchAllRestaurants() {
        ref.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            self.delegate?.didReceive(restaurants: RestaurantBuilder.restaurantsFromJSON(with: snapshot.value as! NSArray))
        })
    }
}
