//
//  RegistrationViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//

import UIKit

class RegistrationViewController: UIViewController {
    struct  Constants {
        static let cornerRadius: CGFloat = 8.0
    }
    
    //  MARK: - Properties
    public let logoLabel: UILabel = {
       let label = UILabel()
        label.text = "DiscUp!"
        label.font = UIFont(name: "Trebuchet MS Bold Italic", size: 28)
        label.textAlignment = .center
        return label
    }()

    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email..."
        field.returnKeyType = .continue
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        
        return field
    }()
    
    private let usernameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Username..."
        field.returnKeyType = .continue
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        
        return field
    }()
    
    private let firstNameField: UITextField = {
        let field = UITextField()
        field.placeholder = "First Name (Optional)..."
        field.returnKeyType = .continue
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        
        return field
    }()
    
    private let lastNameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Last Name (Optional)..."
        field.returnKeyType = .continue
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password..."
        field.returnKeyType = .continue
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        field.isSecureTextEntry = true
        
        return field
    }()
    
    private let confirmPasswordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Confirm Password..."
        field.returnKeyType = .continue
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        field.isSecureTextEntry = true
        
        return field
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.cornerRadius
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        
        return  button
    }()
    
    //  MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        passwordField.delegate = self
        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        view.addSubview(logoLabel)
        view.addSubview(emailField)
        view.addSubview(usernameField)
        view.addSubview(firstNameField)
        view.addSubview(lastNameField)
        view.addSubview(passwordField)
        view.addSubview(confirmPasswordField)
        view.addSubview(registerButton)
        
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        logoLabel.frame = CGRect(x: 20, y: view.safeAreaInsets.top+64, width: view.width-40, height: 48)
        emailField.frame = CGRect(x: 20, y: logoLabel.bottom + 10, width: view.width-40, height: 48)
        usernameField.frame = CGRect(x: 20, y: emailField.bottom + 10, width: view.width-40, height: 48)
        firstNameField.frame = CGRect(x: 20, y: usernameField.bottom + 10, width: view.width-40, height: 48)
        lastNameField.frame = CGRect(x: 20, y: firstNameField.bottom + 10, width: view.width-40, height: 48)
        passwordField.frame = CGRect(x: 20, y: lastNameField.bottom+24, width: view.width-40, height: 48)
        confirmPasswordField.frame = CGRect(x: 20, y: passwordField.bottom+10, width: view.width-40, height: 48)
        registerButton.frame = CGRect(x: 20, y: confirmPasswordField.bottom+24, width: view.width-40, height: 48)
    }
    
    
    //  MARK: - Methods
    @objc func didTapRegisterButton() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let confirm = confirmPasswordField.text, !confirm.isEmpty,
              let username = usernameField.text, !username.isEmpty,
              password == confirm else { return }
        
        var firstName = firstNameField.text
        var lastName = lastNameField.text
        
        if firstName == "" { firstName = nil }
        if lastName == "" { lastName = nil }
        
        AuthManager.registerNewUserWith(email: email, password: password, username: username, firstName: firstName, lastName: lastName) { (success) in
            DispatchQueue.main.async {
                if success {
                    print("successfully registered user.")
                    
                    AuthManager.loginUserWith(email: email, password: password) { (loggedIn) in
                        if loggedIn {
                            print("New firebase user logged in.")
                            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        }
                    }
                    
                } else {
                    print("there was an error registering new firebase user.")
                }
            }
        }
    }
}   //  End of Class

//  MARK: - Extensions
extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            confirmPasswordField.becomeFirstResponder()
        } else if textField == confirmPasswordField {
            didTapRegisterButton()
        }
        return true
    }
}   //  End of Extension

