//
//  EventDetailViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 4/10/21.
//

import UIKit
import SafariServices

class EventDetailViewController: UIViewController {
    //  MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    //  MARK: - PROPERTIES
    var event: Event?
    var eventProperties: [[String]] = []

    //  MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateView()
    }
    
    //  MARK: - METHODS
    func updateView() {
        guard let event = event,
              let propArray = event.propertiesArray(),
              let tableView = self.tableView else { return }
        
        self.title = "\(event.tournament_name ?? "Event Details")"
        
        self.eventProperties = propArray
        tableView.reloadData()
    }
    
    func presentSafariWith(URLString: String) {
        guard let linkURL = URL(string: URLString) else { return }
        let vc = SFSafariViewController(url: linkURL)
        present(vc, animated: true, completion: nil)
    }
}   //  End of Class

extension EventDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventProperties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard let linkCell = tableView.dequeueReusableCell(withIdentifier: "linkCell", for: indexPath) as? LinkTableViewCell else { print("bad cell"); return UITableViewCell() }
        
        let label = eventProperties[indexPath.row][0]
        
        if label == "Event Link" {
            print(eventProperties[indexPath.row][1])
            linkCell.linkLabel.text = label
            
            linkCell.linkButton.setTitle("\(event?.tournament_name ?? "Event")" , for: .normal)
            
            linkCell.tapAction = { _ in
                self.presentSafariWith(URLString: self.event?.event_url ?? "https://www.pdga.com/tour/search")
            }
            return linkCell
            
        } else if label == "Registration Link" {
            print(eventProperties[indexPath.row][1])
            linkCell.linkLabel.text = label
            
            linkCell.linkButton.setTitle("Register" , for: .normal)
            
            linkCell.tapAction = { _ in
                self.presentSafariWith(URLString: self.event?.registration_url ?? "https://www.pdga.com/tour/search")
            }
            return linkCell
            
        } else {
            let value = eventProperties[indexPath.row][1]
            cell.textLabel?.text = "\(label):   \(value)"
            return cell
        }
    }
}   //  End of Extension
