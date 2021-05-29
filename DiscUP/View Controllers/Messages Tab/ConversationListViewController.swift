//
//  CoversationsViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 4/19/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ConversationListViewController: UIViewController {
    //  MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    //  MARK: - PROPERTIES
    var sellingConvos: [ConversationBasic] = []
    var buyingConvos: [ConversationBasic] = []
    let database = MessagingDB.shared.dbRef
    var buyingConvoIDs : [String : Int] = [:]
    var sellingConvoIDs : [String : Int] = [:]
    var newMessageCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        fetchBuyingConvoIDs()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //database.removeAllObservers()
    }
    
    //  MARK: - METHODS
    func fetchBuyingConvoIDs() {
        
        MessagingManager.fetchUserConvosWith(conversationType: .buyingMessages) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let convoIDs):
                    let convoCount = convoIDs.count
                    
                    if convoCount != self.buyingConvoIDs.count {
                        self.buyingConvoIDs = convoIDs
                        self.setObservers(convoIDs: convoIDs)
                        return
                    }
                    
                    self.buyingConvos = []
                    self.fetchBuyingConvos(convoIDs: convoIDs)
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    self.fetchSellingConvoIDs()
                }
            }
        }
    }
    
    func fetchBuyingConvos(convoIDs: [String : Int]) {
        let count = convoIDs.count
        
        var i = 0
        
        for id in convoIDs {
            i += 1
            MessagingManager.getConvoBasicWith(convoID: id.key, userMessageCount: id.value) { convoBasic in
                DispatchQueue.main.async {
                    guard let convoBasic = convoBasic else { return self.fetchSellingConvoIDs() }
                    
                    self.buyingConvos.append(convoBasic)
                    
                    if i == count {
                        self.fetchSellingConvoIDs()
                    }
                }
            }
        }
    }
    
    func fetchSellingConvoIDs() {
        MessagingManager.fetchUserConvosWith(conversationType: .sellingMessages) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let convoIDs):
                    let convoCount = convoIDs.count
                    
                    if convoCount != self.sellingConvoIDs.count {
                        self.sellingConvoIDs = convoIDs
                        self.setObservers(convoIDs: convoIDs)
                        return
                    }
                    
                    self.sellingConvos = []
                    self.fetchSellingConvos(convoIDs: convoIDs)
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    self.updateView()
                }
            }
        }
    }
    
    func fetchSellingConvos(convoIDs: [String : Int]) {
        let count = convoIDs.count
        
        var i = 0
        
        for id in convoIDs {
            i += 1
            MessagingManager.getConvoBasicWith(convoID: id.key, userMessageCount: id.value) { convoBasic in
                DispatchQueue.main.async {
                    
                    if let convoBasic = convoBasic {
                        self.sellingConvos.append(convoBasic)
                    }
                    
                    if i == count {
                        self.updateView()
                    }
                }
            }
        }
    }
    
    func setObservers(convoIDs: [String : Int]) {
        for id in convoIDs {
            database.child(id.key).observe(.value) { _ in
                DispatchQueue.main.async {
                    self.fetchBuyingConvoIDs()
                }
            }
        }
    }
    
    func updateView() {
        self.newMessageCount = 0
        
        for convo in buyingConvos {
            self.newMessageCount += convo.newMessages
        }
        for convo in sellingConvos {
            self.newMessageCount += convo.newMessages
        }
        
        self.tabBarController?.tabBar.items?.last!.badgeValue = newMessageCount.description
        
        if newMessageCount == 0 {
            self.tabBarController?.tabBar.items?.last!.badgeValue = nil
        }
        
        buyingConvos.sort { $0.newMessages > $1.newMessages }
        sellingConvos.sort { $0.newMessages > $1.newMessages }
        self.tableView.reloadData()
    }
    
    func fetchName(nameID: String, completion: @escaping(String) -> Void) {
        UserDB.shared.fetchUserInfoFor(userID: nameID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    if profile.firstName == nil && profile.lastName == nil {
                        completion(profile.username)
                    } else {
                        completion("\(profile.firstName ?? "") \(profile.lastName ?? "")")
                    }
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    completion("")
                }
            }
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toConversationVC" {
            guard let destination = segue.destination as? ConversationViewController,
                  let indexPath = tableView.indexPathForSelectedRow else { return }
            
            if indexPath.section == 1 {
                destination.basicConvo = sellingConvos[indexPath.row]
            } else {
                destination.basicConvo = buyingConvos[indexPath.row]
            }
        }
    }
}   //  End of Class

extension ConversationListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return ("Discs that I'm selling.")
        }

        return "Discs that I'm buying."
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            
            return sellingConvos.count
        }

        return buyingConvos.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ConversationTableViewCell else { return UITableViewCell() }
        
        var convo: ConversationBasic?
        var nameID: String = ""

        if indexPath.section == 1 {
            convo = sellingConvos[indexPath.row]
            nameID = convo?.buyerID ?? ""
        } else {
            convo = buyingConvos[indexPath.row]
            nameID = convo?.sellerID ?? ""
        }

        if let convo = convo {
            cell.itemHeadlilneLabel.text = convo.itemHeadline
            
            let newMessages = convo.newMessages
            
            var newMessagesString = ""
            
            if newMessages > 0 {
                newMessagesString = newMessages.description
                cell.itemHeadlilneLabel.font = .boldSystemFont(ofSize: 18)
                cell.numberNewLabel.font = .boldSystemFont(ofSize: 16)
            }
            
            cell.numberNewLabel.text = newMessagesString
            
            fetchName(nameID: nameID) { name in
                cell.nameLabel.text = name
            }
        }
        
        return cell
    }
}   //  End of Extension
