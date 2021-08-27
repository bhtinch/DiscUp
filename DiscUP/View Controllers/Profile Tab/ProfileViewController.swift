//
//  ProfileViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//

import UIKit
import FirebaseAuth
import AVFoundation
import Photos

enum Settings: String, CaseIterable {
    case resetPassword = "Reset Password"
    case blockedUsers = "Blocked Users"
    case deleteAccount = "Delete Account"
    case logout = "Log Out"
}

class ProfileViewController: UIViewController {
    //  MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var defaultImageButton: UIButton!
    
    //  MARK: - PROPERTIES
    var tableData = Settings.allCases
    var userID = "no user"
    
    //  MARK: - LIFECYLCES
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if let userID = Auth.auth().currentUser?.uid {
            self.userID = userID
            configureViews()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        defaultImageButton.layer.cornerRadius = defaultImageButton.frame.height/2
        defaultImageButton.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        userID = Auth.auth().currentUser?.uid ?? "no user"
        if self.userID == "no user" {
            handleNotAuthenticated()
        } else {
            configureViews()
        }
    }
    
    //  MARK: - ACTIONS
    @IBAction func changeDefaultImageButtonTapped(_ sender: Any) {
        presentImageAlert()
    }
    
    //  MARK: - Methods
    func handleNotAuthenticated() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: false)
    }
    
    func configureViews() {
        MarketManager.fetchImageWith(imageID: userID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.defaultImageButton.setImage(image, for: .normal)
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                }
            }
        }
    }
}   //  End of Class

//  MARK: - IMAGE PICKER AND ALERTS
extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func presentCamera() {
        let camera = UIImagePickerController()
        camera.sourceType = .camera
        camera.delegate = self
        camera.allowsEditing = true
        present(camera, animated: true, completion: nil)
    }
    
    func presentPhotoPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    //  MARK: - PHOTO PICKER METHODS
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        
        if userID != "no user" {
            image.accessibilityIdentifier = userID
            
            StorageManager.uploadImagesWith(images: [image]) { result in
                DispatchQueue.main.async {
                    switch result {
                    
                    case .success(_):
                        self.defaultImageButton.setImage(image, for: .normal)
                    case .failure(let error):
                        print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //  MARK: - ALERTS
    func presentImageAlert() {
        let alert = UIAlertController(title: "Take a photo or choose an image.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
            
            switch MediaPermissions.checkCameraPermission() {
                case .notDetermined:
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        DispatchQueue.main.async {
                            if granted {
                                self.presentCamera()
                                alert.dismiss(animated: true, completion: nil)
                            } else {
                                alert.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                    
                case .restricted:
                    self.presentAlertWith(title: "Your permission settings for this app does not allow taking pictures", message: "Please update the app permissions in order to take photos.")
                    alert.dismiss(animated: true, completion: nil)
                    
                case .denied:
                    self.presentAlertWith(title: "Your permission settings for this app does not allow taking pictures", message: "Please update the app permissions in order to take photos.")
                    alert.dismiss(animated: true, completion: nil)
                    
                case .authorized:
                    self.presentCamera()
                    alert.dismiss(animated: true, completion: nil)
                    
                @unknown default:
                    self.presentAlertWith(title: "Your permission settings for this app does not allow taking pictures", message: "Please update the app permissions in order to take photos.")
                    alert.dismiss(animated: true, completion: nil)
            }
        }
        
        let choosePhotoAction = UIAlertAction(title: "Choose from Gallery", style: .default) { _ in
            
            switch MediaPermissions.checkMediaLibraryPermission() {
                case .notDetermined:
                    PHPhotoLibrary.requestAuthorization { status in
                        DispatchQueue.main.async {
                            switch status {
                                case .authorized:
                                    self.presentPhotoPicker()
                                    alert.dismiss(animated: true, completion: nil)
                                    
                                default:
                                    alert.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                    
                case .authorized:
                    self.presentPhotoPicker()
                    alert.dismiss(animated: true, completion: nil)
                    
                default:
                    self.presentAlertWith(title: "Your permission settings for this app does not allow taking pictures", message: "Please update the app permissions in order to take photos.")
                    alert.dismiss(animated: true, completion: nil)
            }
        }
        
        alert.addAction(takePhotoAction)
        alert.addAction(choosePhotoAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func presentAlertWith(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}   //  End of Extension


//  MARK: - TV DELEGATE & DATA SOURCE
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
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
            self.reauth()
            
        case .logout:
            print("log out tapped...")
            self.logout()
        }
    }
}   //  End of Extension


//  MARK: - SETTINGS METHODS
extension ProfileViewController {
    func logout() {
        AuthManager.logoutUser()
        handleNotAuthenticated()
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
                    self.handleNotAuthenticated()
                case false:
                    Alerts.presentAlertWith(title: "We're Sorry...", message: "This account could not be deleted at this time.", sender: self)
                }
            }
        }
    }
}
