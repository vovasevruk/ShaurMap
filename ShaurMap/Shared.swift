//
//  Shared.swift
//  ShaurMap
//
//  Created by Vova Seuruk on 3/1/17.
//  Copyright © 2017 Vova Seuruk. All rights reserved.
//

import Foundation

class Shared: RestaurantManagerDelegate {
  static let sharedInstance: Shared = {
    let instance = Shared()
    return instance
  }()

  let restaurantsDidUpdateNotification = "restaurantsDidUpdateNotification"
  private(set) var restaurants: [Restaurant]? {
    didSet{
      NotificationCenter.default.post(name: Notification.Name(rawValue: self.restaurantsDidUpdateNotification), object: nil)
    }
  }
  private(set) var manager: RestaurantManager?
  private(set) var isInitialized = false
  private(set) var allRestaurantsAreFetched = false
  
  private init() {
    if !isInitialized {
      manager = RestaurantManager()
      manager?.delegate = self
      manager?.fetchFirstRestaurants(with: 6)
      isInitialized = true
    }
  }
  
  class func loadAllRestaurants() {
    if !sharedInstance.allRestaurantsAreFetched {
      sharedInstance.manager?.fetchAllRestaurants()
      sharedInstance.allRestaurantsAreFetched = true
    }
  }
  
  //MARK: RestaurantManagerDelegate
  func didReceive(restaurants: [Restaurant]) {
    self.restaurants = restaurants
  }
  
  func fetchingRestaurantsDidFail(with error: Error) {
    print("fetching Restaurants did fail with error \(error)")
  }
}
