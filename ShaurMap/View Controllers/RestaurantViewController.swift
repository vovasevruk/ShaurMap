//
//  RestaurantViewController.swift
//  ShaurMap
//
//  Created by Vova Seuruk on 2/23/17.
//  Copyright © 2017 Vova Seuruk. All rights reserved.
//

import UIKit
import GoogleMaps
import SWRevealViewController

class RestaurantViewController: UIViewController {
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var restaurantImageView: UIImageView!
  @IBOutlet weak var restaurantName: UILabel!
  @IBOutlet weak var restaurantAdress: UILabel!
  @IBOutlet weak var businessHours: UILabel!
  @IBOutlet weak var reviewsAndBeenThere: UILabel!
  @IBOutlet weak var beenThere: UIButton!
  @IBOutlet weak var rate: UIButton!
  @IBOutlet weak var ratingLabel: UILabel! { didSet{ print("lol") } }
  weak var commentsView : UIView!
  var menuView : UIView!
  var blurEffectView : UIVisualEffectView!
  var ratingView : UIView!
  var rateButton: UIButton!
  var mapView : UIView!
  
  var restaurant : Restaurant!
  
  /*
   TODO: Add limit to user rates and been here. For example, user can only rate restaurant 1 time and be in restaurant 1 time also. 
 */
  
  override func viewDidLoad() {
    super.viewDidLoad()
    beenThere.addTarget(self, action: #selector(yo), for: .touchUpInside)
    
    createFormatter()
    
    ratingLabel.layer.masksToBounds = true
    ratingLabel.layer.cornerRadius = 5
    
    rate.addTarget(self, action: #selector(rateTapped), for: .touchUpInside)
    
    UIApplication.shared.statusBarStyle = .lightContent
    
    let url = self.restaurant.mainPicture
    DispatchQueue.global().async {
      let data = try? Data(contentsOf: url)
      DispatchQueue.main.async { [weak self] in
        self?.restaurantImageView.image = UIImage(data: data!)
      }
    }
    
    restaurantName.text = restaurant.name
    restaurantAdress.text = restaurant.adressString
    businessHours.attributedText = getAtributedStringFrom(restaurant)
    if restaurant.rating != 0.0 {
      ratingLabel.text = formatter!.string(from: NSNumber(value: Double(restaurant.rating)))
    }
    
    setupBorderAround(button: beenThere)
    setupBorderAround(button: rate)

    addMapView()
    configureMarker()
    
    addMenu()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    UIApplication.shared.statusBarStyle = .default
    
  }
  
  deinit {
    print("\"\(restaurant.name)\" is out of heap")
  }
  
  func yo() {
    print(formatter?.string(from: NSNumber(value: Double(ratingLabel.text!)!)) ?? "-")
  }
  
  var formatter: NumberFormatter?
  private func createFormatter() {
    formatter = NumberFormatter()
    formatter!.numberStyle = .decimal
    formatter!.maximumFractionDigits = 1
  }
  
  //MARK: Button Actions
  @objc private func rateTapped() {
    showBlurEffect()
    showRatingView()
  }
  
  var buttons = [UIButton]()
  var restaurantRating = 0
  private func showRatingView() {
    buttons.removeAll()
    restaurantRating = 0
    ratingView = UIView(frame: CGRect(x: 30, y: 200, width: self.view.frame.width - 60, height: 200))
    ratingView.layer.cornerRadius = 15
    ratingView.backgroundColor = UIColor.white
    self.view.addSubview(ratingView)
    
    let rateLabel = UILabel(frame: CGRect(x: 110, y: 20, width: 120, height: 24))
    rateLabel.text = "Ваша Оценка"
    rateLabel.font = UIFont.init(name: "AvenirNextCondensed-Regular", size: 18.0)
    ratingView.addSubview(rateLabel)
    
    for i in 0..<5 {
      let button = UIButton(frame: CGRect(x: 25 + 45*i + 10*i, y: 60, width: 45, height: 45))
      button.setImage(UIImage(named: "emptyStar"), for: .normal)
      button.setImage(UIImage(named: "filledStar"), for: .selected)
      button.addTarget(self, action: #selector(ratingTapped(button:)), for: .touchUpInside)
      buttons.append(button)
      ratingView.addSubview(button)
    }
    
    rateButton = UIButton(frame: CGRect(x: 110, y: 150, width: 100, height: 40))
    rateButton.setTitle("Оценить", for: .normal)
    rateButton.titleLabel?.font = UIFont.init(name: "AvenirNextCondensed-Regular", size: 20.0)
    rateButton.backgroundColor = UIColor.darkGray
    rateButton.layer.cornerRadius = 10
    rateButton.isEnabled = false
    rateButton.addTarget(self, action: #selector(rated), for: .touchUpInside)
    ratingView.addSubview(rateButton)
  }
  
  @objc private func ratingTapped(button : UIButton) {
    rateButton.isEnabled = true
    for button in buttons {
      button.isSelected = false
    }
    let buttonIndex = Int(buttons.index(of: button)!)
    for i in 0...buttonIndex {
      buttons[i].isSelected = true
    }
    restaurantRating = buttonIndex + 1
  }
  
  @objc private func rated() {
    print("Rating is \(restaurantRating)")
    print("old:\t rating: \(restaurant.rating)\t voted: \(restaurant.voted)")
    let voted = restaurant.voted + 1
    let rating = (restaurant.rating * (Double(voted) - 1.0) + Double(restaurantRating)) / Double(voted)
    restaurant.rating = rating
    restaurant.voted += 1
    print("new:\t rating: \(restaurant.rating)\t voted: \(restaurant.voted)")
    Shared.sharedInstance.manager?.leaveRating(rating, withVotedNumber: voted, for: restaurant.id)
    ratingLabel.text = formatter!.string(from: NSNumber(value: rating))
    
    hideRateView()
  }
  
  @objc private func hideRateView() {
    ratingView.isHidden = true
    blurEffectView.isHidden = true
  }
  
  private func showBlurEffect() {
    let blurEffect = UIBlurEffect(style: .dark)
    blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.alpha = 0.8
    blurEffectView.frame = self.view.bounds
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideRateView))
    blurEffectView.addGestureRecognizer(tapGesture)
    self.view.addSubview(blurEffectView)
  }
  
  private func configureMarker() {
    let marker = GMSMarker()
    marker.position = restaurant.adress.coordinate
    marker.title = restaurant.name
    marker.map = self.mapView as! GMSMapView?
  }
  
  //MARK: UI-Elements
  private func addMenu() {
    menuView = UIView(frame: CGRect(x: 0, y: 555, width: 375, height: restaurant.menu.count * 30))
    menuView.backgroundColor = UIColor.white
    scrollView.addSubview(menuView)
    scrollView.contentSize = CGSize(width: 367, height: 575 + restaurant.menu.count * 30)
    
    addLabels()
  }
  
  private func addMapView() {
    let camera = GMSCameraPosition.camera(withTarget: restaurant.adress.coordinate, zoom: 14)
    let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 410, width: 375, height: 130), camera: camera)
    self.mapView = mapView
    scrollView.addSubview(mapView)
  }
  
  private var menuLabels = [UILabel]()
  
  private func addLabels() {
    var counter = 0
    for (label, value) in restaurant.menu {
      let nameLabel = UILabel(frame: CGRect(x: 10, y: 5 + counter*30, width: 100, height: 20))
      nameLabel.font = UIFont.init(name: "AvenirNextCondensed-Regular", size: 16.0)
      nameLabel.text = label
      nameLabel.textColor = UIColor.black
      
      let isInt = value.truncatingRemainder(dividingBy: 1) == 0
      let price = Int(value)
      
      let additionalSpace: String = ((price / 10 == 0) ? "  " : "")
      let priceLabel = UILabel(frame: CGRect(x: 300, y: 5 + counter*30, width: 60, height: 20))
      priceLabel.font = UIFont.init(name: "AvenirNextCondensed-Regular", size: 16.0)
      priceLabel.text = String(isInt ? String(price) : String(value)) + additionalSpace + " руб."
      counter += 1
      
      menuLabels.append(nameLabel)
      menuLabels.append(priceLabel)
      
      menuView?.addSubview(nameLabel)
      menuView?.addSubview(priceLabel)
    }
  }
  
  //MARK: private coloring funcs
  private let greenColor = UIColor(red: 84/255, green: 231/255, blue: 68/255, alpha: 1)
  private let steelColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
  
  private func setupBorderAround(button: UIButton) {
    button.backgroundColor = .clear
    button.layer.cornerRadius = 20
    button.layer.borderWidth = 1
    button.layer.borderColor = steelColor.cgColor
  }
  
  private func getAtributedStringFrom(_ restaurant : Restaurant) -> NSMutableAttributedString {
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
