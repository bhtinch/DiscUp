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
    @IBOutlet weak var deletePhotoButton: UIButton!
    @IBOutlet weak var headlineTextField: UITextField!
    @IBOutlet weak var manufacturerTextField: UITextField!
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var plasticTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    //  MARK: - PROPERTIES
    
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultImages()
        fetchImages()
    }
    
    //  MARK: - ACTIONS
    @IBAction func addImageButtonTapped(_ sender: Any) {
        var imageCount = 0
        images.forEach { if $0 != UIImage(systemName: "largecircle.fill.circle") {imageCount += 1} }
        
        if imageCount < 5 {
            presentImageAlert()
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        saveOffer()
    }
    
    @IBAction func imageOneButtonTapped(_ sender: Any) {
        featurePhotoAt(index: 1)
    }
    
    @IBAction func imageTwoButtonTapped(_ sender: Any) {
        featurePhotoAt(index: 2)
    }
    
    @IBAction func imageThreeButtonTapped(_ sender: Any) {
        featurePhotoAt(index: 3)
    }
    
    @IBAction func imageFourButtonTapped(_ sender: Any) {
        featurePhotoAt(index: 4)
    }
    
    @IBAction func deletePhotoButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Delete This Photo?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deletePhoto()
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    //  MARK: - METHODS
    func setupDefaultImages() {
        guard let defaultImage = UIImage(systemName: "largecircle.fill.circle") else { return }
        
        for _ in 0..<5 {
            images.append(defaultImage)
        }
        
        deletePhotoButton.isHidden = true
    }
    
    func featurePhotoAt(index: Int) {
        print("featuring photo at index \(index)")
        
        let feature = images.remove(at: index)
        images.insert(feature, at: 0)
        
        updateViews()
    }
    
    func fetchImages() {
        updateViews()
    }
    
    func updateViews() {
        mainImageView.image = images[0]
        imageOneView.image = images[1]
        imageTwoView.image = images[2]
        imageThreeView.image = images[3]
        imageFourView.image = images[4]
        
        if mainImageView.image != UIImage(systemName: "largecircle.fill.circle") {
            deletePhotoButton.isHidden = false
        } else {
            deletePhotoButton.isHidden = true
        }
    }
    
    func deletePhoto() {
        images.removeFirst()
        images.append(UIImage(systemName: "largecircle.fill.circle") ?? UIImage())
        updateViews()
    }
    
    func saveOffer() {
        guard let headline = headlineTextField.text, !headline.isEmpty,
              let manufacturer = manufacturerTextField.text, !manufacturer.isEmpty,
              let model = modelTextField.text, !model.isEmpty,
              let description = descriptionTextView.text, !description.isEmpty else { return presentAlertWith(title: "Please complete all required fields", message: nil) }
        
        let plastic = plasticTextField.text
        
        var weight: Double?
        if let weightText = weightTextField.text {
            weight = Double(weightText)
        }
        
        let item = MarketItem(headline: headline, manufacturer: manufacturer, model: model, plastic: plastic, weight: weight, description: description)
        
        MarketManager.createNewOfferWith(item: item) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("successfully saved offer...")
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                }
            }
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

}   //  End of Class

extension MyOfferDetailViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
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
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
              let index = images.firstIndex(of: UIImage(systemName: "largecircle.fill.circle") ?? UIImage()) else { return }
        
        self.images.insert(image, at: index)
        
        if index == 4 { self.addImageButton.isEnabled = false }
        
        self.updateViews()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}   //  End of Extension

extension MyOfferDetailViewController {
    //  MARK: - ALERTS
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
    
    func presentAlertWith(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}   //  End of Extension
