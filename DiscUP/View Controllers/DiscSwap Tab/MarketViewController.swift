//
//  MarketViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//

import UIKit

class MarketViewController: UIViewController {
    //  MARK: - OUTLETS
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}   //  End of Class

extension MarketViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    //  MARK: - COLLECTION VIEW DATA SOURCE
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "marketItemCell", for: indexPath) as? MarketCollectionViewCell else { return UICollectionViewCell() }
        
        return cell
    }
    
    //  MARK: - COLLECTION VIEW FLOW LAYOUT
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width / 2
        return CGSize(width: width * 0.9, height: width * 1.3)
    }
}   //  End of Extension
