//
//  DiscSearchTableViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//

import UIKit
import FirebaseDatabase

class DiscSearchTableViewController: UITableViewController {
    //  MARK: - Outlets and Properties
    @IBOutlet weak var searchBar: UISearchBar!
    
    var currentBagID: String = "No bag."
    var filteredDiscList: [Disc] = []
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
        
    //  MARK: - Methods
    func presentAddDiscAlertWith(disc: Disc) {
        let alertController = UIAlertController(title: "\(disc.model) by \(disc.make)", message: "Add To Your bag??", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Bag it!", style: .default) { (_) in
            let bagID = self.currentBagID
            BagManager.addDiscWith(discID: disc.uid, discModel: disc.model, toBagWith: bagID)
            self.searchBarCancelButtonClicked(self.searchBar)
            print("bagged")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        })
        
        let showDetailAction = UIAlertAction(title: "Disc Details", style: .default) { (_) in
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let controller = storyboard.instantiateViewController(withIdentifier: "DiscDetailViewController") as? DiscDetailViewController else { return }
            
            controller.selectedDisc = disc
            controller.bagID = self.currentBagID

            self.present(controller, animated: true, completion: nil)
        }
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        alertController.addAction(showDetailAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDiscList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "discCell", for: indexPath)
        
        cell.textLabel?.text = self.filteredDiscList[indexPath.row].model
        cell.detailTextLabel?.text = self.filteredDiscList[indexPath.row].make
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let disc = filteredDiscList[indexPath.row]
        presentAddDiscAlertWith(disc: disc)
    }
}   //  End of Class

extension DiscSearchTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search button tapped...")
        
        guard let searchTerm = searchBar.text?.lowercased() else { return }
        DiscDB.shared.filterDiscsByMakeOrModelWith(searchTerm: searchTerm) { (discs) in
            DispatchQueue.main.async {
                self.filteredDiscList = discs
                self.tableView.reloadData()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Canceled Search.")
        searchBar.text = ""
        self.filteredDiscList = []
        self.tableView.reloadData()
    }
}   //  End of Extension
