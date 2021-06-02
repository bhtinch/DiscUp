//
//  EventsViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//

import UIKit

class EventSearchViewController: UIViewController {
    //  MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var copyrightLabel: UILabel!
    
    //  MARK: - PROPERTIES
    var events: [Event] = []
    var loginResponse: LoginResponse?
    var eventName: String?
    var state: String?
    var startDate: String?
    
    //  MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        copyrightLabel.isHidden = true
    }
    
    //  MARK: - ACTIONS
    @IBAction func searchButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Search For Events", message: "Enter any combination of the search options below", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addTextField { (tf) in
            tf.placeholder = "event name..."
        }
        alert.addTextField { (tf) in
            tf.placeholder = "state (2 letter abbrev. only)..."
        }
        alert.addTextField { (tf) in
            tf.placeholder = "start date (YYYY-MM-DD)..."
        }
        
        let searchAction = UIAlertAction(title: "Search", style: .default) { (_) in
            self.events = []
            
            guard let nameTF = alert.textFields?[0],
                  let stateTF = alert.textFields?[1],
                  let dateTF = alert.textFields?[2] else { return }
            
            if nameTF.text != nil && !nameTF.text!.isEmpty {
                self.eventName = nameTF.text!
            }
            if stateTF.text != nil && !stateTF.text!.isEmpty {
                self.state = stateTF.text!.uppercased()
            }
            if dateTF.text == nil || dateTF.text!.isEmpty {
                self.startDate = Date().dateToString(format: .searchedDate)
            } else if dateTF.text != nil && !dateTF.text!.isEmpty {
                self.startDate = dateTF.text!
            }
            
            self.loginToApiServer()
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(searchAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        print("Clear button clicked.")
        self.events = []
        self.tableView.reloadData()
        copyrightLabel.isHidden = true
    }
    
    //  MARK: - METHODS
    func loginToApiServer() {
        ApiController.login { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.loginResponse = response
                    self.searchEventsWith(eventName: self.eventName, state: self.state, startDate: self.startDate)
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func searchEventsWith(eventName: String?, state: String?, startDate: String?) {
        guard let loginResponse = self.loginResponse else { return }
        ApiController.getEventsBy(eventName: eventName, state: state, startDate: startDate, loginResponse: loginResponse) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let events):
                    self.events = events
                    self.tableView.reloadData()
                    self.copyrightLabel.isHidden = false
                    self.eventName = nil
                    self.state = nil
                    self.startDate = nil
                    self.logoutOfApiServer()
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    self.logoutOfApiServer()
                }
            }
        }
    }
    
    func logoutOfApiServer() {
        guard let loginResponse = self.loginResponse else { return }
        ApiController.logout(loginResponse: loginResponse) { (result) in
            DispatchQueue.main.async {
                switch result  {
                case .success(_):
                    print("\nSuccessfully logged out of server...\n")
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEventDetailVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destination = segue.destination as? EventDetailViewController else { return }
            destination.event = events[indexPath.row]
        }
    }
}   //  End of Class

extension EventSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let eventCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventTableViewCell else { return UITableViewCell() }
            let event = events[indexPath.row]
        
        eventCell.dateLabel.text = event.configureStartDate() ?? "Date"
        eventCell.eventNameLabel.text = event.tournament_name ?? "Unknown Tournament"
        eventCell.eventLocationLabel.text = "\(event.city ?? "Unknown"), \(event.state_prov ?? "Unknown")"
        
        
        
        if event.tier == "L" { eventCell.tierLabel.text = "League" } else {
            eventCell.tierLabel.text = "Tier \(event.tier ?? "Unknown")"
        }

        if let tier = event.tier {
            switch tier {
            case "L":
                eventCell.tierLabel.backgroundColor = .darkGray
            case "NT":
                eventCell.tierLabel.backgroundColor = .systemOrange
            case "B":
                eventCell.tierLabel.backgroundColor = .systemGreen
            case "C":
                eventCell.tierLabel.backgroundColor = .blue
            case "M":
                eventCell.tierLabel.backgroundColor = .purple
            case "A":
                eventCell.tierLabel.backgroundColor = .systemIndigo
            case "DGPT":
                eventCell.tierLabel.backgroundColor = .black
            case "XM":
                eventCell.tierLabel.backgroundColor = .systemTeal
            case "XA":
                eventCell.tierLabel.backgroundColor = .systemGray
            case "XB":
                eventCell.tierLabel.backgroundColor = .link
            case "XC":
                eventCell.tierLabel.backgroundColor = .systemRed
            default:
                eventCell.tierLabel.backgroundColor = .white
            }
        }
        
        if event.status != "sanctioned" { eventCell.logoImage.isHidden = true }
        return eventCell
    }
}   //  End of Extension
