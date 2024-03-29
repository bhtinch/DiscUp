//
//  BagsViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//
import FirebaseDatabase
import FirebaseAuth
import UIKit

class BagViewController: UIViewController {
    //  MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //  MARK: - Properties
    var userID = Auth.auth().currentUser?.uid ?? "No User"
    var discs: [Disc] = []
    var discIDs: [String] = []
    var bagID: String?
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Logged In UserID: \(userID)")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let bagID = bagID else { return fetchDefaultBag() }
        fetchBag(bagID: bagID)
    }
    
    //  MARK: - Methods
    func fetchDefaultBag() {
        BagManager.getDefaultBag { (result) in
            switch result {
            case .success(let bag):
                print("successfully fetched default Bag with ID: \(bag.uuidString)")
                self.title = bag.name
                self.bagID = bag.uuidString
                
                self.discIDs = []
                for id in bag.discIDs.keys {
                    self.discIDs.append(id)
                }
                self.fetchDiscs()
                
            case .failure(let error):
                switch error {
                case .databaseError:
                    print(error)
                case .noData:
                    print(error)
                    self.presentCreateBagAlert()
                case .invalidURL:
                    print(error)
                case .thrownError(_):
                    print(error)
                case .unableToDecode:
                    print(error)
                case .unableToLogin:
                    print(error)
                case .noUser:
                    print(error)
                case .failedToUploadToStorage:
                    print(error)
                case .failedToGetDownloadURL:
                    print(error)
                }
            }
        }
    }
    
    func fetchBag(bagID: String) {
        BagManager.getBagWith(bagID: bagID) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let bag):
                    print("successfully fetched Bag with ID: \(bag.uuidString)")
                    self.bagID = bag.uuidString
                    
                    self.discIDs = []
                    
                    bag.discIDs.keys.forEach {
                        self.discIDs.append($0)
                    }
                    print(self.discIDs)
                    self.fetchDiscs()
                    
                case .failure(let error):
                    switch error {
                    case .databaseError:
                        print(error)
                    case .noData:
                        self.discs = []
                        self.tableView.reloadData()
                    case .invalidURL:
                        print(error)
                    case .thrownError(_):
                        print(error)
                    case .unableToDecode:
                        print(error)
                    case .unableToLogin:
                        print(error)
                    case .noUser:
                        print(error)
                    case .failedToUploadToStorage:
                        print(error)
                    case .failedToGetDownloadURL:
                        print(error)
                    }
                }
            }
        }
    }
    
    func fetchDiscs() {
        self.discs = []
        
        if discIDs.isEmpty {
            tableView.reloadData()
            return
        }
        
        for uid in discIDs {
            DiscDB.shared.getDiscWith(uid: uid) { (result) in
                switch result {
                case .success(let disc):
                    self.discs.append(disc)
                        self.tableView.reloadData()
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func presentCreateBagAlert() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CreateNewBagViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //  MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDiscDetailVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destination = segue.destination as? DiscDetailViewController else { return }
            guard let bagID = bagID else { return }
            destination.bagID = bagID
            destination.selectedDisc = discs[indexPath.row]
            destination.bagItButton.isHidden = true
        }
        
        if segue.identifier == "toDiscSearchVC" {
            guard let destination = segue.destination as? DiscSearchTableViewController else { return }
            guard let bagID = bagID else { return }
            destination.currentBagID = bagID
        }
        
        if segue.identifier == "toSwitchBagTVC" {
            guard let destination = segue.destination as? SwitchBagTableViewController else { return }
            destination.delegate = self
        }
    }
    
}   //  End of Class


//  MARK: - Extensions
extension BagViewController: SwitchBagTableViewDelegate {
    func send(bagID: String, bagName: String) {
        print("Selected Bag Name: \(bagName)")
        print("Selected Bag ID: \(bagID)")
        self.title = bagName
        self.bagID = bagID
    }
}

extension BagViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "discCell", for: indexPath) as? BaggedDiscTableViewCell else { return UITableViewCell() }
        
        cell.textLabel?.text = discs[indexPath.row].model
        cell.detailTextLabel?.text = discs[indexPath.row].make
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let discID = discIDs[indexPath.row]
            guard let bagID = bagID else { return }
            BagManager.removeDiscWith(discID: discID, fromBagWith: bagID)
            fetchBag(bagID: bagID)
        }
    }
}
