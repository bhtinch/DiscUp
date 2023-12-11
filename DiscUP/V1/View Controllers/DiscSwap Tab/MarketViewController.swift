//
//  MarketViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//

import UIKit
import CoreLocation

class MarketViewController: UIViewController {
    //  MARK: - OUTLETS
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var useLocationButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var noResultsLabel: UILabel!
    
    //  MARK: - PROPERTIES
    var items: [MarketItemBasic] = []
    var deleteImageIDs: [String] = []
    var usingCurrentLocation: Bool = true
    var location: Location?
    let locationManager = LocationManager.shared
    
    //  MARK: - LIFECYLCES
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        zipCodeTextField.delegate = self
        
        searchBar.delegate = self
        
        usingCurrentLocation = false
        useLocationButtonTapped(self)
        
        noResultsLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        prepareToFetchItems()
    }
    
    //  MARK: - ACTIONS
    @IBAction func useLocationButtonTapped(_ sender: Any) {
        print("tapped")
        
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            self.presentAlertWith(title: "Your permission settings for this app does not allow location capture", message: "Please update the app permissions in order to use this feature. Otherwise, simply use a zip code to specify location.")
            self.useLocationButton.isEnabled = false
            self.usingCurrentLocation = false
            
        case .denied:
            self.presentAlertWith(title: "Your permission settings for this app does not allow location capture", message: "Please update the app permissions in order to use this feature. Otherwise, simply use a zip code to specify location.")
            self.useLocationButton.isEnabled = false
            self.usingCurrentLocation = false

        case .authorizedAlways:
            if let latitude = locationManager.location?.coordinate.latitude,
               let longitude = locationManager.location?.coordinate.longitude {
                self.location = Location(latitude: latitude, longitude: longitude)
                self.useLocationButton.isEnabled = true
                configureLocationButton()
            }
            
        case .authorizedWhenInUse:
            if let latitude = locationManager.location?.coordinate.latitude,
               let longitude = locationManager.location?.coordinate.longitude {
                self.location = Location(latitude: latitude, longitude: longitude)
                self.useLocationButton.isEnabled = true
                configureLocationButton()
            }
            
        @unknown default:
            self.presentAlertWith(title: "Your permission settings for this app does not allow location capture", message: "Please update the app permissions in order to use this feature. Otherwise, simply use a zip code to specify location.")
            self.useLocationButton.isEnabled = false
            self.usingCurrentLocation = false
        }
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        self.prepareToFetchItems()
    }
    
    
    //  MARK: - METHODS
    func configureLocationButton() {
        let status = locationManager.authorizationStatus
        usingCurrentLocation.toggle()
        
        if usingCurrentLocation {
            useLocationButton.setTitleColor(.white, for: .normal)
            useLocationButton.backgroundColor = .link
            zipCodeTextField.text = nil
            zipCodeTextField.resignFirstResponder()
        } else if usingCurrentLocation == false && status == .authorizedAlways || status == .authorizedWhenInUse {
            useLocationButton.setTitleColor(.link, for: .normal)
            useLocationButton.backgroundColor = .white
        }
    }
    
    func prepareToFetchItems() {
        items = []
        noResultsLabel.isHidden = true
        self.collectionView.reloadData()
        
        //  get location from either zipCodeTextField or using current location
        if usingCurrentLocation == false {
            guard let zip = zipCodeTextField.text, !zip.isEmpty else {
                if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                presentAlertWith(title: "Please enter a zip code or use select 'Use Current Location'.", message: nil)
                } else {
                    presentAlertWith(title: "Please enter a zip code to search.", message: nil)
                }
                
                return
            }
            
            guard zip.count == 5 else { return self.presentAlertWith(title: "Please enter a valid zip code.", message: nil) }
            
            self.locationManager.getCoordinates(zipCode: zip) { result in
                DispatchQueue.main.async {
                    switch result {
                    
                    case .success(let clLocation):
                        let location = Location(latitude: clLocation.latitude, longitude: clLocation.longitude)
                        
                        self.fetchItemIDsWith(location: location)
                        
                    case .failure(let error):
                        print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                        
                        return self.presentAlertWith(title: "Please enter a valid zip code.", message: nil)
                    }
                }
            }
        } else {
            guard let location = self.location else { return }
            fetchItemIDsWith(location: location)
        }
    }
    
    func fetchItemIDsWith(location: Location) {
        MarketManager.fetchOfferIDsWithin(range: .kilometers(10), of: location) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let itemIDs):
                    if itemIDs.isEmpty {
                        self.noResultsLabel.isHidden = false
                        self.collectionView.reloadData()
                    } else {
                        self.noResultsLabel.isHidden = true
                        self.fetchOffersWith(itemIDs: itemIDs)
                    }
                    
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchOffersWith(itemIDs: [String]) {
        var allItems: [MarketItemBasic] = []
        
        for id in itemIDs {
            MarketManager.fetchMarketBasicItemWith(itemID: id) { itemBasic in
                DispatchQueue.main.async {
                    allItems.append(itemBasic)
                    
                    if id == itemIDs.last {
                        self.filterOffersWith(allItems: allItems)
                    }
                }
            }
        }
    }
    
    func filterOffersWith(allItems: [MarketItemBasic]) {
        guard let searchTerm = searchBar.text?.lowercased(), !searchTerm.isEmpty else {
            self.items = allItems
            self.collectionView.reloadData()
            return
        }
        
        for item in allItems {
            if item.headline.localizedCaseInsensitiveContains(searchTerm) || item.manufacturer.localizedCaseInsensitiveContains(searchTerm) || item.model.localizedCaseInsensitiveContains(searchTerm) {
                items.append(item)
            }
        }
        
        if items.isEmpty { noResultsLabel.isHidden = false }
        self.collectionView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMarketItemDetailVC" {
            guard let indexPath = collectionView.indexPathsForSelectedItems?.first,
                  let destination = segue.destination as? MarketItemDetailViewController else { return }
            destination.itemID = items[indexPath.row].id
        }
    }

}   //  End of Class

extension MarketViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    //  MARK: - COLLECTION VIEW DATA SOURCE
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "marketItemCell", for: indexPath) as? MarketCollectionViewCell else { return UICollectionViewCell() }
        
        let item = items[indexPath.row]
        
        MarketManager.fetchImageWith(imageID: item.thumbImageID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    cell.thumbnailImageView.image = image
                case .failure(_):
                    print("Error fetching thumbImage for item with ID: \(item.id)")
                    cell.thumbnailImageView.image = UIImage(systemName: "largecircle.fill.circle")
                }
            }
        }
                
        cell.headlineLabel.text = item.headline
        cell.sublineLabel.text = "\(item.manufacturer) \(item.model)"
        cell.bottomLabel.text = item.plastic
        
        return cell
    }
    
    //  MARK: - COLLECTION VIEW FLOW LAYOUT
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width / 2
        return CGSize(width: width * 0.9, height: width * 1.3)
    }
}   //  End of Extension

extension MarketViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search button tapped...")
        self.searchButtonTapped(self)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Canceled Search.")
        searchBar.text = ""
        self.items = []
        self.collectionView.reloadData()
    }
    
}   //  End of Extension

extension MarketViewController {
    //  MARK: - ALERTS
    func presentAlertWith(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}   //  End of Extension

extension MarketViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == zipCodeTextField {
            if usingCurrentLocation {
                useLocationButtonTapped(self)
            }
        }
    }
}   //  End of Extension

