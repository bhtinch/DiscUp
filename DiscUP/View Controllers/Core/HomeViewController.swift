//
//  HomeViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//

import FirebaseAuth
import UIKit

class HomeViewController: UIViewController {
    
    //  MARK: - Properties
    var userID = Auth.auth().currentUser?.uid ?? "No User"

    override func viewDidLoad() {
        super.viewDidLoad()

        handleNotAuthenticated()
    }
    
    //  MARK: - Methods
    func handleNotAuthenticated() {
        if self.userID == "No User" {
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: false)
        }
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
