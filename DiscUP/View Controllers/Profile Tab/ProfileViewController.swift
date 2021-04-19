//
//  ProfileViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //  MARK: - Outlets
    @IBOutlet weak var profileBackgroundImage: UIImageView!
    @IBOutlet weak var profileDefaultImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    //  MARK: - PROPERTIES
    var userID = Auth.auth().currentUser?.uid ?? "No User"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleNotAuthenticated()
        configureViews()
    }
    
    @IBAction func changeDefaultImageButtonTapped(_ sender: Any) {
    }
    
    @IBAction func changeBackgroundImageButtonTapped(_ sender: Any) {
    }
    
    //  MARK: - Methods
    func handleNotAuthenticated() {
        if self.userID == "No User" {
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: false)
        }
    }
    
    func configureViews() {
        tableView.delegate = self
        tableView.dataSource = self
        
        profileDefaultImage.layer.borderWidth = 2.0
        profileDefaultImage.layer.borderColor = UIColor.systemGray.cgColor
        profileDefaultImage.layer.masksToBounds = false
        profileDefaultImage.clipsToBounds = true
        profileDefaultImage.layer.cornerRadius = profileDefaultImage.height/2.1
    }
    
    
    //  MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
