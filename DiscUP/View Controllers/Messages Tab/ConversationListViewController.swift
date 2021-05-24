//
//  CoversationsViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 4/19/21.
//

import UIKit
import FirebaseAuth

class ConversationListViewController: UIViewController {
    //  MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    //  MARK: - PROPERTIES
    var sellingConvos: [ConversationBasic] = []
    var buyingConvos: [ConversationBasic] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchBuyingConvoIDs()
    }
    
    //  MARK: - METHODS
    func fetchBuyingConvoIDs() {
        
        MessagingManager.fetchUserConvosWith(conversationType: .buyingMessages) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let convoIDs):
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
    
    func updateView() {
        
        buyingConvos.sort { $0.newMessages > $1.newMessages }
        sellingConvos.sort { $0.newMessages > $1.newMessages }
        self.tableView.reloadData()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toConversationVC" {
            guard let destination = segue.destination as? ConversationViewController,
                  let indexPath = tableView.indexPathForSelectedRow else { return }
            
            if indexPath.section == 1 {
                destination.convoID = sellingConvos[indexPath.row].id
            } else {
                destination.convoID = buyingConvos[indexPath.row].id
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var convo: ConversationBasic?

        if indexPath.section == 1 {
            convo = sellingConvos[indexPath.row]
        } else {
            convo = buyingConvos[indexPath.row]
        }

        if let convo = convo {
            cell.textLabel?.text = convo.itemHeadline
            
            let newMessages = convo.newMessages
            
            var newMessagesString = ""
            
            if newMessages > 0 { newMessagesString = newMessages.description }
            
            cell.detailTextLabel?.text = newMessagesString
        }
        
        return cell
    }
}   //  End of Extension
