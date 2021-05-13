//
//  MyOffersViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 4/19/21.
//

import UIKit

class MyOffersViewController: UIViewController {
    //  MARK: - OUTLETS
    @IBOutlet weak var collectionView: UICollectionView!
    
    //  MARK: - PROPERTIES
    var items: [MarketItem] = []
    
    //  MARK: - LIFECYLCES
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchMyOffers()
    }
    
    //  MARK: - METHODS
    func fetchMyOffers() {
        MarketManager.fetchMyOffers { result in
            DispatchQueue.main.async {
                switch result {
                
                case .success(let items):
                    print("successfully fetched my offers.")
                    self.items = items
                    self.collectionView.reloadData()
                    
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMyOfferDetailVC" {
            guard let indexPath = collectionView.indexPathsForSelectedItems?.first,
                  let destination = segue.destination as? MyOfferDetailViewController else { return }
            destination.item = items[indexPath.row]
        }
        
        if segue.identifier == "newOfferSegue" {
            guard let destination = segue.destination as? MyOfferDetailViewController else { return }
            destination.isNew = true
            destination.item = nil
        }
    }

}   //  End of Class

extension MyOffersViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    //  MARK: - COLLECTION VIEW DATA SOURCE
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "marketItemCell", for: indexPath) as? MarketCollectionViewCell else { return UICollectionViewCell() }
        
        let item = items[indexPath.row]
        
        cell.thumbnailImageView.image = item.images.first ?? UIImage(systemName: "largecircle.fill.circle")
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

