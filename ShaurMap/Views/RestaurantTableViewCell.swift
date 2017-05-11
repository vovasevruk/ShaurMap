//
//  Restaurant1TableViewCell.swift
//  ShaurMap
//
//  Created by Vova Seuruk on 2/22/17.
//  Copyright © 2017 Vova Seuruk. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {
  @IBOutlet weak var restaurantImageView: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var adress: UILabel!
  @IBOutlet weak var businessHours: UILabel!
  @IBOutlet weak var distance: UILabel!
  var id: String!
  
  override func prepareForReuse() {
    super.prepareForReuse()
    restaurantImageView.image = nil
    name.text = ""
    adress.text = ""
    businessHours.text = ""
    distance.text = ""
    id = ""
  }
  
  func configure(with restaurant: Restaurant) {
    self.name.text = restaurant.name
    self.id = String(describing: restaurant.smallPicture)
    self.businessHours.text = "Работает с \(restaurant.openHour):00 до \(restaurant.closeHour):00"
    self.adress.text = restaurant.adressString
    self.restaurantImageView.sd_setImage(with: URL(string: String(describing: restaurant.smallPicture)), placeholderImage: nil)
  }
}
