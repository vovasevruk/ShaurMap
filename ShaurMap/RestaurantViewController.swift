//
//  RestaurantViewController.swift
//  ShaurMap
//
//  Created by Vova Seuruk on 2/23/17.
//  Copyright © 2017 Vova Seuruk. All rights reserved.
//

import UIKit
import GoogleMaps

class RestaurantViewController: UIViewController {
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var restaurantImageView: UIImageView!
  @IBOutlet weak var restaurantName: UILabel!
  @IBOutlet weak var restaurantAdress: UILabel!
  @IBOutlet weak var businessHours: UILabel!
  @IBOutlet weak var reviewsAndBeenThere: UILabel!
  @IBOutlet weak var beenThere: UIButton!
  @IBOutlet weak var share: UIButton!
  @IBOutlet weak var segmentControl: UISegmentedControl!
  
  var restaurant : Restaurant!
  var mapView : UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIApplication.shared.statusBarStyle = .lightContent
    
    DispatchQueue.global().async {
      let data = try? Data(contentsOf: self.restaurant.mainPicture)
      DispatchQueue.main.async {
        self.restaurantImageView.image = UIImage(data: data!)
      }
    }
    
    restaurantName.text = restaurant.name
    restaurantAdress.text = restaurant.adressString
    businessHours.attributedText = getAtributedStringFrom(restaurant)
    
    setupBorderAround(button: beenThere)
    setupBorderAround(button: share)
    
    let camera = GMSCameraPosition.camera(withTarget: restaurant.adress.coordinate, zoom: 14)
    let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 465, width: 375, height: 130), camera: camera)
    self.mapView = mapView
    view.addSubview(mapView)
    
    let marker = GMSMarker()
    marker.position = restaurant.adress.coordinate
    marker.title = restaurant.name
    marker.map = mapView
    
    print(restaurant.menu)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    UIApplication.shared.statusBarStyle = .default
  }
  
  let greenColor = UIColor(red: 84/255, green: 231/255, blue: 68/255, alpha: 1)
  let steelColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
  
  func setupBorderAround(button: UIButton) {
    button.backgroundColor = .clear
    button.layer.cornerRadius = 20
    button.layer.borderWidth = 1
    button.layer.borderColor = steelColor.cgColor
  }
  
  func getAtributedStringFrom(_ restaurant : Restaurant) -> NSMutableAttributedString {
    var isOpened = false
    let nowHour = Calendar.current.component(.hour, from: Date())
    if nowHour >= restaurant.openHour , nowHour <= restaurant.closeHour { isOpened = true }
    // if 0 > restaurant.closeHour > 8 need special logic
    if restaurant.closeHour >= 0, restaurant.closeHour <= 8 {
      if nowHour <= restaurant.openHour , nowHour >= restaurant.closeHour {
        isOpened = false
      } else {
        isOpened = true
      }
    }
    let result = "\((isOpened) ? "Открыто" : "Закрыто") • Сегодня с \(restaurant.openHour):00 до \(restaurant.closeHour):00"
    
    let statusRange = NSRange(location: 0, length: 7)
    let textRange = NSRange(location: 7, length: result.characters.count - 7)
    let statusColor = [NSForegroundColorAttributeName: (isOpened) ? greenColor : .red]
    let textColor = [NSForegroundColorAttributeName: UIColor.black]
    
    let attrString = NSMutableAttributedString(string: result)
    attrString.addAttributes(statusColor, range: statusRange)
    attrString.addAttributes(textColor, range: textRange)
    
    return attrString
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
