//
//  SettingsViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    //  MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    //  MARK: - PROPERTIES
    var tableData = Settings.allCases
    var userID: String = "no user"
    
    //  MARK: - LIFECYLCE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //    //  MARK: - Actions
    //    @IBAction func logOutButtonTapped(_ sender: Any) {
    //        AuthManager.logoutUser()
    //        self.userID = "No User"
    //        self.handleNotAuthenticated()
    //    }
    
    //  MARK: - METHODS
    func logout() {
        AuthManager.logoutUser()
        self.userID = "no user"
        self.navigationController?.popViewController(animated: true)
    }
    
    func sendResetPasswordEmail() {
        let alert = UIAlertController(title: "Password Reset Email", message: "Would you like to an email sent to you to reset your password?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        let sendEmailAction = UIAlertAction(title: "Send Email", style: .default) { (_) in
            AuthManager.sendUserPasswordResetEmail { (success) in
                if success {
                    let message = "Password reset email successfully sent."
                    AuthManager.presentActionUpdateAlert(with: message, sender: self)
                    
                } else {
                    let message = "Whoops! An error occurred attempting to send a password reset email."
                    AuthManager.presentActionUpdateAlert(with: message, sender: self)
                }
                alert.dismiss(animated: true, completion: nil)
            }
        }
        
        alert.addAction(sendEmailAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
     // MARK: - Navigation
//     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toBlockedUsersVC" {
//            print("going to blockedUsersVC")
//        }
//     }
    
}   //  End of Class

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        cell.textLabel?.text = tableData[indexPath.row].rawValue
        cell.textLabel?.textColor = .link
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = tableData[indexPath.row]
        
        switch option {
        case .changeEmail:
            print("change email tapped...")
            
        case .changePassword:
            print("change password tapped...")
            
        case .resetPassword:
            print("reset password tapped...")
            self.sendResetPasswordEmail()
            
        case .blockedUsers:
            print("blocked users tapped...")
            performSegue(withIdentifier: "toBlockedUsersVC", sender: self)
            
        case .deleteAccount:
            print("delete account tapped...")
            
        case .logout:
            print("log out tapped...")
            self.logout()
            
        case .privacyPolicy:
            print("privacy policy tapped...")
            
        }
    }
}   //  End of Extension

enum Settings: String, CaseIterable {
    case changeEmail = "Change Email"
    case changePassword = "Change Password"
    case resetPassword = "Reset Password"
    case blockedUsers = "Blocked Users"
    case deleteAccount = "Delete Account"
    case logout = "Log Out"
    case privacyPolicy = "Privacy Policy"
}
