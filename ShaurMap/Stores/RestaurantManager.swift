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
  
  weak var delegate : RestaurantManagerDelegate?
  
  func fetchFirstRestaurants(with amout: Int) {
    print("fetching first rests")
    ref.queryLimited(toFirst: UInt(amout)).observeSingleEvent(of: .value, with: { (snapshot) in
      self.delegate?.didReceive(restaurants: RestaurantBuilder.restaurantsFromJSON(with: snapshot.value as! NSArray))
      print("delegate method back")
    })
  }

  func fetchAllRestaurants() {
    ref.observe(.value, with: { (snapshot) in
      self.delegate?.didReceive(restaurants: RestaurantBuilder.restaurantsFromJSON(with: snapshot.value as! NSArray))
      print("fetching all")
    })
  }
  
  func leaveRating(_ rating: Double, withVotedNumber voted: Int, for id: Int) {
    ref.child("\(id)").child("rating").setValue(String(rating))
    ref.child("\(id)").child("voted").setValue(String(voted))
  }
}
