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
    var ref: FIRDatabaseReference!
    
    var delegate : RestaurantManagerDelegate?

    func fetchRestaurants() {
        ref = FIRDatabase.database().reference()
        
        ref.child("restaurants").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            self.delegate?.didReceive(restaurants: RestaurantBuilder.restaurantsFromJSON(with: snapshot.value as! NSDictionary))
        })
    }
}
