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

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //  MARK: - Outlets
    @IBOutlet weak var profileBackgroundImage: UIImageView!
    @IBOutlet weak var profileDefaultImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    //  MARK: - PROPERTIES
    var userID = "no user"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userID = Auth.auth().currentUser?.uid ?? "no user"
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.userID == "no user" {
            handleNotAuthenticated()
        }
    }
    
    @IBAction func changeDefaultImageButtonTapped(_ sender: Any) {
        presentImageAlert()
    }
    
    @IBAction func changeBackgroundImageButtonTapped(_ sender: Any) {
    }
    
    //  MARK: - Methods
    func handleNotAuthenticated() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: false)
    }
    
    func configureViews() {
        tableView.delegate = self
        tableView.dataSource = self
        
        profileDefaultImage.layer.borderWidth = 2.0
        profileDefaultImage.layer.borderColor = UIColor.clear.cgColor
        profileDefaultImage.layer.masksToBounds = false
        profileDefaultImage.clipsToBounds = true
        profileDefaultImage.layer.cornerRadius = profileDefaultImage.height/2.1
        
        MarketManager.fetchImageWith(imageID: userID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.profileDefaultImage.image = image
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                }
            }
        }
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
    
}   //  End of Class

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
                        self.profileDefaultImage.image = image
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
