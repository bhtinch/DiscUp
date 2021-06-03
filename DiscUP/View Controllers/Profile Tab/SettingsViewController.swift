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
    
    //  MARK: - METHODS
    func logout() {
        AuthManager.logoutUser()
        self.performSegue(withIdentifier: "noUserToProfile", sender: self)
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
        
    func reauth() {
        guard let user = Auth.auth().currentUser else { return Alerts.presentAlertWith(title: "We're Sorry...", message: "This account could not be deleted at this time.", sender: self) }
        
        let alert = UIAlertController(title: "Delete Your Account?", message: "Would you like to delete your account? This cannot be undone. Please reauthenticate your account to delete.", preferredStyle: .alert)
        
        alert.addTextField { tf in
            tf.placeholder = "Login Email..."
        }
        
        alert.addTextField { tf in
            tf.placeholder = "Password..."
            tf.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        let deleteAction = UIAlertAction(title: "DELETE", style: .destructive) { (_) in
            guard let email = alert.textFields?.first?.text, !email.isEmpty,
            let password = alert.textFields?.last?.text, !password.isEmpty else {
                Alerts.presentAlertWith(title: "Please enter your login information", message: nil, sender: self)
                return }

            AuthManager.reauthenticateUser(email: email, password: password) { success in
                DispatchQueue.main.async {
                    switch success {
                    case true:
                        self.deleteAccount()
                    case false:
                        return Alerts.presentAlertWith(title: "We're Sorry...", message: "The login information provided does not match out system. Please try again.", sender: self)
                    }
                }
            }
        }
        
        alert.addAction(deleteAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func deleteAccount() {
        AuthManager.deleteUser { success in
            DispatchQueue.main.async {
                switch success {
                case true:
                    self.performSegue(withIdentifier: "noUserToProfile", sender: self)
                case false:
                    Alerts.presentAlertWith(title: "We're Sorry...", message: "This account could not be deleted at this time.", sender: self)
                }
            }
        }
    }
    
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     }
    
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
        case .resetPassword:
            print("reset password tapped...")
            self.sendResetPasswordEmail()
            
        case .blockedUsers:
            print("blocked users tapped...")
            performSegue(withIdentifier: "toBlockedUsersVC", sender: self)
            
        case .deleteAccount:
            print("delete account tapped...")
            self.deleteAccount()
            
        case .logout:
            print("log out tapped...")
            self.logout()
        }
    }
}   //  End of Extension

enum Settings: String, CaseIterable {
    case resetPassword = "Reset Password"
    case blockedUsers = "Blocked Users"
    case deleteAccount = "Delete Account"
    case logout = "Log Out"
}
