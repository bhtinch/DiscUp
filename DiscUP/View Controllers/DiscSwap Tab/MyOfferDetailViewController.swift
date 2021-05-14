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
    var isNew: Bool = true
    var itemID: String?
    var item: MarketItem?
    var deleteImageIDs: [String] = []
    
    //  MARK: - LIFECYLCES
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupDefaultImages()
        
        if let _ = itemID {
            self.isNew = false
            self.fetchItem()
        }
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
        updateViews()
    }
    
    func featurePhotoAt(index: Int) {
        print("featuring photo at index \(index)")
        
        let feature = images.remove(at: index)
        images.insert(feature, at: 0)
        
        updateViews()
    }
    
    func fetchItem() {
        guard let itemID = itemID else { return }
        
        MarketManager.fetchItemWith(itemID: itemID) { item in
            DispatchQueue.main.async {
                guard let item = item else { return print("Error fetching item details...") }
                self.item = item
                self.configureThumbImage()
            }
        }
    }
    
    func configureThumbImage() {
        guard let item = item else { return }
        
        MarketManager.fetchImageWith(imageID: item.thumbImageID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    image.accessibilityIdentifier = item.thumbImageID
                    self.images[0] = image
                    self.configureImages()
                    
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    self.updateViews()
                }
            }
        }
    }
    
    func configureImages() {
        guard let item = item,
              item.imageIDs.first != "", !item.imageIDs.isEmpty else { return updateViews() }
        
        var i = 1
        
        for id in item.imageIDs {
            
            MarketManager.fetchImageWith(imageID: id) { result in
                DispatchQueue.main.async {
                    switch result {
                    
                    case .success(let image):
                        image.accessibilityIdentifier = id
                        self.images[i] = image
                        self.updateViews()
                        i += 1
                        
                    case .failure(let error):
                        print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                        self.updateViews()
                    }
                }
            }
        }
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
        
        if let item = item, isNew == false {
            headlineTextField.text = item.headline
            manufacturerTextField.text = item.manufacturer
            modelTextField.text = item.model
            plasticTextField.text = item.plastic
            weightTextField.text = item.weight?.description
            descriptionTextView.text = item.description
        }
    }
    
    func deletePhoto() {
        let deletedImage = images.removeFirst()
        images.append(UIImage(systemName: "largecircle.fill.circle") ?? UIImage())
        
        if let deletedID = deletedImage.accessibilityIdentifier { self.deleteImageIDs.append(deletedID) }
        
        self.updateViews()
    }
    
    func saveOffer() {
        //  if there is no itemID (isNew == true) set one using a random uuid
        let itemID = itemID ?? UUID().uuidString
        
        //  get info from textfields and textview
        guard let headline = headlineTextField.text, !headline.isEmpty,
              let manufacturer = manufacturerTextField.text, !manufacturer.isEmpty,
              let model = modelTextField.text, !model.isEmpty,
              let description = descriptionTextView.text, !description.isEmpty else { return presentAlertWith(title: "Please complete all required fields", message: nil) }
        
        //  check that there is at least one photo provided
        guard let thumbImage = images.first, thumbImage != UIImage(systemName: "largecircle.fill.circle") else { return presentAlertWith(title: "Please provide at least one image of your item!", message: nil) }
                
        let plastic = plasticTextField.text
        
        //  get weight String from textfield, if present, and convert to Double
        var weight: Double?
        if let weightText = weightTextField.text {
            weight = Double(weightText)
        }
        
        //  create an array of images to add to the MarketItem object
        var imageIDs: [String] = []
        var uploadImages: [UIImage] = []
        
        var saveItem: MarketItem?
        
        for image in images where image != images.first {
            if image != UIImage(systemName: "largecircle.fill.circle") {
                if image.accessibilityIdentifier == nil {
                    image.accessibilityIdentifier = "\(itemID)_\(UUID().uuidString)"
                    uploadImages.append(image)
                }
                guard let imageID = image.accessibilityIdentifier else { return print("no image ID!") }
                imageIDs.append(imageID)
            }
        }
        
        var thumbImageID = thumbImage.accessibilityIdentifier
        
        if thumbImageID == nil {
            thumbImageID = "\(itemID)_\(UUID().uuidString)"
            thumbImage.accessibilityIdentifier = thumbImageID
            uploadImages.append(thumbImage)
        }
        
        saveItem = MarketItem(id: itemID, headline: headline, manufacturer: manufacturer, model: model, plastic: plastic, weight: weight, description: description, imageIDs: imageIDs, thumbImageID: thumbImageID!)
        
        if let updateItem = saveItem {            
            MarketManager.update(item: updateItem, uploadImages: uploadImages, deletedImageIDs: self.deleteImageIDs) { result in
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
    }
    
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
