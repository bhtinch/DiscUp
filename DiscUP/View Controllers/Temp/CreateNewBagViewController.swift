//
//  CreateNewBagViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//

import UIKit

class CreateNewBagViewController: UIViewController {
       
    //  MARK: - outlets
    @IBOutlet weak var bagNameTextField: UITextField!
    @IBOutlet weak var bagBrandTextField: UITextField!
    @IBOutlet weak var bagModelTextField: UITextField!
    @IBOutlet weak var bagColorTextField: UITextField!
    @IBOutlet weak var uncheckedButton: UIButton!
    @IBOutlet weak var checkedButton: UIButton!
    @IBOutlet weak var defaultStackView: UIStackView!
    
    var isDefault: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkedButton.isHidden = true
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

        BagManager.createNewBagWith(name: name, brand: brand, model: model, color: color, isDefault: isDefault)
                
        self.navigationController?.popViewController(animated: true)
    }
}
