//
//  BlockedUsersTableViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/24/21.
//

import UIKit

class BlockedUsersTableViewController: UITableViewController {

    //  MARK: - PROPERTIES
    var blockedUserIDs: [String] = []
    var blockedUsers: [UserProfile] = []
    
    //  MARK: -  LIFECYCLES
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchBlockedUserIDs()
    }
    
    //  MARK: - METHODS
    func fetchBlockedUserIDs() {
        blockedUserIDs = []
        blockedUsers = []
        
        MessagingManager.fetchBlockedUsers { blockedUserIDs in
            self.blockedUserIDs = blockedUserIDs
            self.fetchBlockedProfiles()
        }
    }
    
    func fetchBlockedProfiles() {
        for id in blockedUserIDs {
            UserDB.shared.fetchUserInfoFor(userID: id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let profile):
                        self.blockedUsers.append(profile)
                        self.tableView.reloadData()
                    case .failure(let error):
                        print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func presentCheckAlert(userProfile: UserProfile) {
        let alert = UIAlertController(title: "Do you want to unblock this user:", message: "\(userProfile.username) ?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        let unblockAction = UIAlertAction(title: "Unblock", style: .destructive, handler: { (_) in
            MessagingManager.unblockUserWith(id: userProfile.id, blockedUserIDs: self.blockedUserIDs, completion: { _ in
                self.tableView.reloadData()
                alert.dismiss(animated: true, completion: nil)
            })
        })
        
        alert.addAction(unblockAction)
        
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedUsers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let profile = blockedUsers[indexPath.row]
        
        cell.textLabel?.text = profile.username
        cell.detailTextLabel?.text = "\(profile.firstName ?? "") \(profile.lastName ?? "")"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userProfile = blockedUsers[indexPath.row]
        
        presentCheckAlert(userProfile: userProfile)
    }
}   //  End of Class
