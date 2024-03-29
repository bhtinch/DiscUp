//
//  MarketItemDetailViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 4/19/21.
//

import UIKit
import CoreLocation
import FirebaseAuth

class MarketItemDetailViewController: UIViewController {
    //  MARK: - OUTLETS
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var imageOneView: UIImageView!
    @IBOutlet weak var imageTwoView: UIImageView!
    @IBOutlet weak var imageThreeView: UIImageView!
    @IBOutlet weak var imageFourView: UIImageView!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var listedTimeLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var messageSellerButton: UIButton!
    @IBOutlet weak var sellerImageView: UIImageView!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var manufacturerValueLabel: UILabel!
    @IBOutlet weak var moldValueLabel: UILabel!
    @IBOutlet weak var plasticValueLabel: UILabel!
    @IBOutlet weak var weightValueLabel: UILabel!
    @IBOutlet weak var priceValueLabel: UILabel!
    @IBOutlet weak var imagesStackView: UIStackView!
    @IBOutlet weak var contentView: UIView!
    
    //  MARK: - PROPERTIES
    var itemID: String?
    var images: [UIImage] = []
    var item: MarketItem?
    var ownerID: String?
    let locationManager = LocationManager.shared
    var ownerProfile: UserProfile?

    //  MARK: - LIFECYCLES
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.isEditable = false
        
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        descriptionTextView.layer.cornerRadius = 6
        
        sellerImageView.layer.masksToBounds = false
        sellerImageView.clipsToBounds = true
        sellerImageView.layer.cornerRadius = sellerImageView.height/2.1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let _ = itemID {
            fetchItem()
        }
    }
    
    //  MARK: - ACTIONS
    @IBAction func imageOneButtonTapped(_ sender: Any) {
        featurePhotoAt(index: 1)
    }
    
    @IBAction func imageTwoButtonTapped(_ sender: Any) {
        featurePhotoAt(index: 2)
    }
    
    @IBAction func imageThreeButtonTapped(_ sender: Any) {
        featurePhotoAt(index: 3)
    }
    
    @IBAction func imageFourButtonTapped(_ sender: Any) {
        featurePhotoAt(index: 4)
    }
    
    @IBAction func messageSellerButtonTapped(_ sender: Any) {
        guard let item = item else { return }
        
        let vc = ConversationViewController()
        vc.item = item
        
        //  check if convo for this specific item already exists for the current user (buyer)
        UserDB.shared.checkIfConversationExistsForCurrentUserWith(itemID: item.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let convoID):
                    //  if so push to conversation VC with convoID and isNewConvo = false
                    
                    MessagingManager.getConvoBasicWith(convoID: convoID, userMessageCount: nil) { basicConvo in
                        DispatchQueue.main.async {
                            if let basicConvo = basicConvo {
                                vc.basicConvo = basicConvo
                                vc.isNewConvo = false
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    }
                    
                case .failure(let error):
                    switch error {
                    case .noData:
                        //  if not push with newConvo
                        vc.basicConvo = nil
                        vc.isNewConvo = true
                        self.navigationController?.pushViewController(vc, animated: true)

                    default:
                        print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    //  MARK: - METHODS
    func featurePhotoAt(index: Int) {
        print("featuring photo at index \(index)")
        
        let feature = images.remove(at: index)
        
        if feature == UIImage(systemName: "largecircle.fill.circle") { return images.insert(feature, at: index) }
        
        images.insert(feature, at: 0)
        
        updateImageViews()
    }
    
    func fetchItem() {
        guard let itemID = itemID else { return }
        
        images = []
        
        MarketManager.fetchItemWith(itemID: itemID) { item in
            DispatchQueue.main.async {
                guard let item = item else {
                    print("Error fetching item details...")
                    Alerts.presentAlertWith(title: "This item could not be found.  It may not be available anymore.", message: nil, sender: self)
                    return
                }
                
                self.item = item
                self.ownerID = item.ownerID
                self.configureThumbImage()
                self.updateViews()
            }
        }
    }
    
    func configureThumbImage() {
        guard let item = item else { return }
        
        MarketManager.fetchImageWith(imageID: item.thumbImageID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    image.accessibilityIdentifier = item.thumbImageID
                    self.images.append(image)
                    self.configureImages()
                    
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    self.updateViews()
                }
            }
        }
    }
    
    func configureImages() {
        guard let item = item,
              item.imageIDs.first != "", !item.imageIDs.isEmpty else {
            updateImageViews()
            return
        }
                
        for id in item.imageIDs {
            
            MarketManager.fetchImageWith(imageID: id) { result in
                DispatchQueue.main.async {
                    switch result {
                    
                    case .success(let image):
                        image.accessibilityIdentifier = id
                        self.images.append(image)
                        
                        if id == item.imageIDs.last {
                            self.updateViews()
                            self.updateImageViews()
                        }
                                                
                    case .failure(let error):
                        print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                        self.updateViews()
                    }
                }
            }
        }
    }
    
    func updateImageViews() {
        guard !images.isEmpty else { return }
        mainImageView.image = images[0]
        
        for i in 1..<images.count {
            switch i {
            case 1:
                imageOneView.image = images[i]
            case 2:
                imageTwoView.image = images[i]
            case 3:
                imageThreeView.image = images[i]
            case 4:
                imageFourView.image = images[i]
            default:
                return
            }
        }
    }
    
    func updateViews() {
        var listedDuration: TimeInterval?
        var listedDurationOutput: String = ""
        
        var itemLocation: Location = Location(latitude: 0, longitude: 0)
        var city: String = ""
        var state: String = ""
                
        if let item = item {
            headlineLabel.text = item.headline
            manufacturerValueLabel.text = item.manufacturer
            moldValueLabel.text = item.model
            plasticValueLabel.text = item.plastic
            weightValueLabel.text = item.weight?.description
            descriptionTextView.text = item.description
            listedDuration = Date().timeIntervalSince(item.updatedTimestamp)
            itemLocation = item.sellingLocation
            
            if let price = item.askingPrice?.description {
                priceValueLabel.isHidden = false
                priceValueLabel.text = "$\(price)"
            } else {
                priceValueLabel.isHidden = true
            }
        }
        
        locationManager.getPlacemarkFrom(location: itemLocation) { placemark in
            DispatchQueue.main.async {
                if let placemark = placemark {
                    city = placemark.locality ?? "unknown city"
                    state = placemark.administrativeArea ?? "unknown state"
                }
                
                if let durationDbl = listedDuration {
                    
                    let duration = Int(durationDbl)
                    
                    switch duration {
                    case 0..<3600:
                        listedDurationOutput = "Listed \(duration / 60) mins ago in \(city), \(state)."
                        
                    case 3600..<14400:
                        let div = duration.quotientAndRemainder(dividingBy: 60)
                        listedDurationOutput = "Listed \(div.quotient) hrs and \(div.remainder / 60) mins ago in \(city), \(state)."
                        
                    case 14400..<86400:
                        let div = duration.quotientAndRemainder(dividingBy: 3600)
                        var hours = div.quotient
                        if div.remainder >= 1800 { hours += 1}
                        listedDurationOutput = "Listed \(hours) hrs ago in \(city), \(state)."
                        
                    case 86400..<172800:
                        let div = duration.quotientAndRemainder(dividingBy: 86400)
                        listedDurationOutput = "Listed \(div.quotient) days and \(div.remainder / 3600) hrs ago in \(city), \(state)."
                        
                    case 172800...:
                        let div = duration.quotientAndRemainder(dividingBy: 86400)
                        var days = div.quotient
                        if div.remainder >= (86400 / 2) { days += 1}
                        listedDurationOutput = "Listed \(days) days ago in \(city), \(state)."
                        
                    default:
                        listedDurationOutput = "unknown"
                    }
                }
                
                self.listedTimeLabel.text = listedDurationOutput
                
                self.fetchSellerInfo()
            }
        }
        
        
        
    }
    
    func fetchSellerInfo() {
        guard let ownerID = self.ownerID else { return }
        
        UserDB.shared.fetchUserInfoFor(userID: ownerID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let ownerProfile):
                    if ownerProfile.firstName == nil && ownerProfile.lastName == nil {
                        self.sellerNameLabel.text = ownerProfile.username
                    } else {
                        self.sellerNameLabel.text = "\(ownerProfile.firstName ?? "") \(ownerProfile.lastName ?? "")"
                    }
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                }
            }
        }
        
        MarketManager.fetchImageWith(imageID: ownerID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.sellerImageView.image = image
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                }
            }
        }
    }

}   //  End of Class
