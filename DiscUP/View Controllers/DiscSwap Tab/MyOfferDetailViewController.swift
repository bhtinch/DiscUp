//
//  MyOfferDetailViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 4/19/21.
//

import UIKit

class MyOfferDetailViewController: UIViewController {
    //  MARK: - OUTLETS
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var imageOneView: UIImageView!
    @IBOutlet weak var imageTwoView: UIImageView!
    @IBOutlet weak var imageThreeView: UIImageView!
    @IBOutlet weak var imageFourView: UIImageView!
    
    //  MARK: - PROPERTIES
    
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultImages()
        fetchImages()
    }
    
    //  MARK: - ACTIONS
    @IBAction func addImageButtonTapped(_ sender: Any) {
        presentImageAlert()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
    }
    
    @IBAction func imageOneButtonTapped(_ sender: Any) {
        print("image 1 Button Tapped")
    }
    
    @IBAction func imageTwoButtonTapped(_ sender: Any) {
        print("image 2 Button Tapped")
    }
    
    @IBAction func imageThreeButtonTapped(_ sender: Any) {
        print("image 3 Button Tapped")
    }
    
    @IBAction func imageFourButtonTapped(_ sender: Any) {
        print("image 4 Button Tapped")
    }
    
    //  MARK: - METHODS
    func setupDefaultImages() {
        guard let defaultImage = UIImage(systemName: "largecircle.fill.circle") else { return }
        
        for i in 0..<5 {
                        
            switch i {
            case 0:
                images.append(defaultImage.withTintColor(.blue))
            case 1:
                images.append(defaultImage.withTintColor(.orange))
            case 2:
                images.append(defaultImage.withTintColor(.systemIndigo))
            case 3:
                images.append(defaultImage.withTintColor(.cyan))
            case 4:
                images.append(defaultImage.withTintColor(.magenta))
            default:
                return
            }
        }
    }
    
    func fetchImages() {
        updateViews()
    }
    
    func updateViews() {
        mainImageView.image = images.first ?? UIImage(systemName: "largecircle.fill.circle")
        imageOneView.image = images[1]
        imageTwoView.image = images[2]
        imageThreeView.image = images[3]
        imageFourView.image = images[4]
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

extension MyOfferDetailViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func presentImageAlert() {
        let alert = UIAlertController(title: "Take a photo or choose an image.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
            self.presentCamera()
            alert.dismiss(animated: true, completion: nil)
        }
        
        let choosePhotoAction = UIAlertAction(title: "Choose from Gallery", style: .default) { _ in
            self.presentPhotoPicker()
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(takePhotoAction)
        alert.addAction(choosePhotoAction)
        
        present(alert, animated: true, completion: nil)
    }
    
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
        self.images.append(image)
        self.updateViews()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}   //  End of Extension
