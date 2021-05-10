//
//  CreateNewBagViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//

import UIKit

class CreateNewBagViewController: UIViewController {
       
    //  MARK: - outlets
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var bagNameTextField: UITextField!
    @IBOutlet weak var bagBrandTextField: UITextField!
    @IBOutlet weak var bagModelTextField: UITextField!
    @IBOutlet weak var bagColorTextField: UITextField!
    @IBOutlet weak var uncheckedButton: UIButton!
    @IBOutlet weak var checkedButton: UIButton!
    @IBOutlet weak var defaultStackView: UIStackView!
    @IBOutlet weak var createButton: UIButton!
    
    var isDefault: Bool = false
    var isNew = true
    var bagID: String? {
        didSet {
            getBagInfoWith(bagID: bagID)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkedButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if isNew == false {
            headingLabel.text = "Edit Your Bag"
            createButton.setTitle("Save", for: .normal)
        }
    }
    
    //  MARK: - Actions
    @IBAction func uncheckedButtonTapped(_ sender: Any) {
        checkedButton.isHidden = false
        isDefault = true
    }
    
    @IBAction func checkButtonTapped(_ sender: Any) {
        checkedButton.isHidden = true
        isDefault = false
    }
    
    @IBAction func createButtonTapped(_ sender: Any) {
        guard let name = bagNameTextField.text, !name.isEmpty else { return }
        let brand = bagBrandTextField?.text ?? "null"
        let model = bagModelTextField?.text ?? "null"
        let color = bagColorTextField?.text ?? "null"
        
        if isNew {
            BagManager.createNewBagWith(name: name, brand: brand, model: model, color: color, isDefault: isDefault)
            self.navigationController?.popViewController(animated: true)
        } else {
            guard let bagID = self.bagID else { return }
            
            BagManager.editBagWith(bagID: bagID, name: name, brand: brand, model: model, color: color, isDefault: isDefault) { result in
                switch result {
                case .success(_):
                    print("bag successfully updated")
                    self.navigationController?.popViewController(animated: true)
                    
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                }
            }
        }
    }
    
    //  MARK: - METHODS
    func getBagInfoWith(bagID: String?) {
        guard let bagID = bagID else { return }
        BagManager.getBagWith(bagID: bagID) { result in
            switch result {
            case .success(let bag):
                self.bagNameTextField.text = bag.name
                self.bagBrandTextField.text = bag.brand
                self.bagModelTextField.text = bag.model
                self.bagColorTextField.text = bag.color
                if bag.isDefault {
                    self.checkedButton.isHidden = false
                    self.uncheckedButton.isHidden = true
                    self.isDefault = true
                } else {
                    self.checkedButton.isHidden = true
                    self.uncheckedButton.isHidden = false
                    self.isDefault = false
                }
            case .failure(let error):
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
            }
        }

    }
}
