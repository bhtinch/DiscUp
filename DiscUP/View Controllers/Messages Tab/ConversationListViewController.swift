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
    var convos: [ConversationBasic] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchConversationsBasic()
    }
    
    //  MARK: - METHODS
    func fetchConversationsBasic() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toConversationVC" {
            guard let destination = segue.destination as? ConversationViewController,
                  let indexPath = tableView.indexPathForSelectedRow else { return }
            destination.convoID = convos[indexPath.row].id
        }
    }
}   //  End of Class

extension ConversationListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return convos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let convo = convos[indexPath.row]
        
        cell.textLabel?.text = convo.itemHeadline
        cell.textLabel?.text = convo.newMessages.description
        
        return cell
    }
    
    
}   //  End of Class
