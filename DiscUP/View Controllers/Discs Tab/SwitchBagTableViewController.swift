//
//  SwitchBagTableViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//

import FirebaseDatabase
import UIKit

protocol SwitchBagTableViewDelegate: AnyObject {
    func send(bagID: String, bagName: String)
}

class SwitchBagTableViewController: UITableViewController {
    
    //  MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getBaglist()
    }
    
    //  MARK: - Actions
    @IBAction func createBagButtonTapped(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "CreateNewBagViewController")
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true, completion: nil)
    }
    
    //  MARK: - Properties
    var bags: [[String]] = []
    weak var delegate: SwitchBagTableViewDelegate?
    
    //  MARK: - Methods
    func getBaglist() {
        bags = []
        let pathString = "\(UserKeys.userID)/\(UserKeys.bags)"
        
        UserDB.shared.dbRef.child(pathString).observeSingleEvent(of: .value) { (snap) in
            DispatchQueue.main.async {
                for child in snap.children {
                    guard let childSnap = child as? DataSnapshot else { return }
                    let bagID = childSnap.key as String
                    let bagName  = childSnap.childSnapshot(forPath: BagKeys.name).value as? String ?? "Unnamed"
                    
                    let bag = [bagName, bagID]
                    self.bags.append(bag)
                }
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return bags.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "switchBagCell", for: indexPath)
        
        let bagName = bags[indexPath.row][0]
        cell.textLabel?.text = bagName

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bagName = self.bags[indexPath.row][0]
        let bagID = self.bags[indexPath.row][1]
        delegate?.send(bagID: bagID, bagName: bagName)
        navigationController?.popViewController(animated: true)
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            BagManager.deleteBagWith(bagID: bags[indexPath.row][1]) { success in
                switch success {
                case .success(_):
                    self.getBaglist()
                case .failure(_):
                    print("no bag found when attempting to delete bagID: \(self.bags[indexPath.row][1])")
                }
            }
            
        }
    }
}   //  End of Class
