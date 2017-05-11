import UIKit
import CoreLocation
import SWRevealViewController

class MainPageViewController: UIViewController, UIScrollViewDelegate {
  @IBOutlet weak var sales: UIButton!
  @IBOutlet weak var restaurants: UIButton!
  @IBOutlet weak var nearMe: UIButton!
  @IBOutlet weak var feedback: UIButton!
  @IBOutlet weak var menuButton: UIBarButtonItem!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var pageControl: UIPageControl!
  
  private struct Constants {
    static let statusBarHeight = 20.0
    static let navigationBarHeight = 44.0
  }
  
  private struct Storyboard {
    static let showRestaurants = "show Restaurants"
    static let showNearMe = "show near me"
  }
  
  var userLocation : CLLocation?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    scrollView.delegate = self
    makeButtonsRounded()
    
    if !LocationService.sharedInstance.isActive {
      LocationService.sharedInstance.delegate = self
      LocationService.sharedInstance.startUpdatingLocation()
    }
    
    if self.revealViewController() != nil {
      menuButton.target = self.revealViewController()
      menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
      self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    if !Shared.sharedInstance.isInitialized {
      _ = Shared.sharedInstance
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    configureScrollView()
    configurePageControl()
    
    pageControl.addTarget(self, action: #selector(changePage), for: .valueChanged)
  }
  
  func makeButtonsRounded () {
    sales.layer.cornerRadius = sales.frame.width / 2
    restaurants.layer.cornerRadius = restaurants.frame.width / 2
    nearMe.layer.cornerRadius = nearMe.frame.width / 2
    feedback.layer.cornerRadius = feedback.frame.width / 2
  }
  
  func configureScrollView() {
    let scrollViewHeight = self.scrollView.frame.height
    let scrollViewWidth = self.scrollView.frame.width
    
    let imageView1 = UIImageView(frame: CGRect(x: 0, y: 0, width: scrollViewWidth, height: scrollViewHeight))
    let imageView2 = UIImageView(frame: CGRect(x: scrollViewWidth, y: 0, width: scrollViewWidth, height: scrollViewHeight))
    let imageView3 = UIImageView(frame: CGRect(x: scrollViewWidth * 2, y: 0, width: scrollViewWidth, height: scrollViewHeight))
    
    imageView1.image = UIImage(named: "1")
    imageView2.image = UIImage(named: "2")
    imageView3.image = UIImage(named: "3")
    
    scrollView.addSubview(imageView1)
    scrollView.addSubview(imageView2)
    scrollView.addSubview(imageView3)
    
    scrollView.contentSize = CGSize(width: scrollViewWidth * 3, height: scrollViewHeight)
  }
  
  func configurePageControl() {
    self.pageControl.numberOfPages = 3
    self.pageControl.currentPage = 0
  }
  
  func changePage() -> () {
    let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
    scrollView.setContentOffset(CGPoint(x: x, y: 0.0), animated: true)
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
    pageControl.currentPage = Int(pageNumber)
  }
}

extension MainPageViewController : LocationServiceDelegate {
  func tracingLocation(_ currentLocation: CLLocation) {
    userLocation = currentLocation
  }
  
  func tracingLocationDidFailtWith(error: NSError) {
    print(error)
  }
}
