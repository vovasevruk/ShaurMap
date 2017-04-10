//
//  RestaurantsTableViewController.swift
//  ShaurMap
//
//  Created by Vova Seuruk on 2/21/17.
//  Copyright © 2017 Vova Seuruk. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseDatabase
import Firebase
import Foundation

class RestaurantsTableViewController: UITableViewController {
  @IBOutlet weak var menuButton: UIBarButtonItem!
  
  var userLocation : CLLocation?
  var restaurants = [Restaurant]()
  
  private struct Storyboard {
    static let restaurantCellIdentifier = "restaurantCell"
    static let showRestaurant = "show Restaurant"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    
    if let restaurantList = Shared.sharedInstance.restaurants {
      restaurants = restaurantList
    }
    
    createFormatter()
    
    if self.revealViewController() != nil {
      menuButton.target = self.revealViewController()
      menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
      self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    LocationService.sharedInstance.delegate = self
    userLocation = LocationService.sharedInstance.currentLocation
    
    NotificationCenter.default.addObserver(self, selector: #selector(getUpdatedRestaurants),
                                           name: Notification.Name(rawValue: Shared.sharedInstance.restaurantsDidUpdateNotification), object: nil)
  }
  
  //MARK: Notifications
  @objc private func getUpdatedRestaurants() {
    restaurants = Shared.sharedInstance.restaurants!
    tableView.reloadData()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Shared.sharedInstance.restaurantsDidUpdateNotification), object: nil)
  }
  
  //MARK: UITableViewDelegate
  override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    if !Shared.sharedInstance.allRestaurantsAreFetched {
      Shared.loadAllRestaurants()
    }
  }
  
  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return restaurants.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.restaurantCellIdentifier, for: indexPath) as! RestaurantTableViewCell
    
    let restaurant = restaurants[indexPath.row]
    
    cell.name.text = restaurant.name
    cell.businessHours.text = "Работает с \(restaurant.openHour):00 до \(restaurant.closeHour):00"
    cell.distance.text = getDistanceFrom(restaurant: restaurant)
    cell.adress.text = restaurant.adressString
    DispatchQueue.global().async {
      let data = try? Data(contentsOf: restaurant.smallPicture)
      DispatchQueue.main.async {
        cell.restaurantImageView.image = UIImage(data: data!)!
      }
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: Storyboard.showRestaurant, sender: indexPath)
  }
  
  //MARK: Distance func
  var formatter: NumberFormatter!
  private func createFormatter() {
    formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 1
  }
  
  
  func getDistanceFrom(restaurant: Restaurant) -> String{
    if  userLocation != nil{
      let distanceToCafeInKM = userLocation!.distance(from: restaurant.adress) / 1000
      if distanceToCafeInKM > 100{
        return "> 100 км"
      } else if distanceToCafeInKM < 0.1{
        return "< 100 метров"
      } else{
        return formatter.string(from: NSNumber(value: distanceToCafeInKM))! + " км"
      }
    } else {return "неизвестно"}
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.showRestaurant {
      let destinationVC = segue.destination as! RestaurantViewController
      destinationVC.restaurant = restaurants[(sender as! IndexPath).row]
    }
  }
}

extension RestaurantsTableViewController : LocationServiceDelegate{
  func tracingLocation(_ currentLocation: CLLocation) {
    userLocation = currentLocation
    tableView.reloadData()
  }
  
  func tracingLocationDidFailtWith(error: NSError) {
    print(error)
  }
}
