//
//  RestaurantManagerDelegate.swift
//
//
//  Created by Vova Seuruk on 2/27/17.
//
//

import Foundation

protocol RestaurantManagerDelegate : class {
  func didReceive(restaurants: [Restaurant])
  func fetchingRestaurantsDidFail(with error: Error)
}
