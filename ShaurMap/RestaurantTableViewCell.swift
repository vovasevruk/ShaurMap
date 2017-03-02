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
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
