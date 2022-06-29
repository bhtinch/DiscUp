//
//  LoginViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//

import UIKit

class LoginViewController: UIViewController {
    
    //  MARK: - Outlets
    
    struct Constants {
        static let cornerRadius: CGFloat = 8.0
    }
    
    public let logoLabel: UILabel = {
       let label = UILabel()
        label.text = "DiscUp!"
        label.font = UIFont(name: "Trebuchet MS Bold Italic", size: 28)
        label.textAlignment = .center
        return label
    }()
    
    public let usernameEmailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Username or Email"
        field.returnKeyType = .next
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        
        return  field
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
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.cornerRadius
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        
        return  button
    }()
    
    private let createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Create New Account", for: .normal)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccountButton), for: .touchUpInside)
        
        
        usernameEmailField.delegate = self
        passwordField.delegate = self
        addSubviews()
        
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        logoLabel.frame = CGRect(x: 24.0, y: view.safeAreaInsets.top + 64, width: view.width - 48, height: 48)
        usernameEmailField.frame = CGRect(x: 24.0, y: logoLabel.bottom + 64, width: view.width - 48, height: 48)
        passwordField.frame = CGRect(x: 24, y: usernameEmailField.bottom + 8, width: view.width - 48, height: 48)
        loginButton.frame = CGRect(x: 24, y: passwordField.bottom + 8, width: view.width - 48, height: 48)
        createAccountButton.frame = CGRect(x: 24, y: loginButton.bottom + 8, width: view.width - 48, height: 48)
    }
    
    private func addSubviews() {
        view.addSubview(logoLabel)
        view.addSubview(usernameEmailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(createAccountButton)
    }
    
    @objc func didTapLoginButton() {
        
        guard let email = usernameEmailField.text, !email.isEmpty else { return }
        
        guard let password = passwordField.text, !password.isEmpty else { return }
        
        AuthManager.loginUserWith(email: email, password: password) { (success) in
            DispatchQueue.main.async {
                if success {
                    //  user logged in
                    self.dismiss(animated: true, completion: nil)
                } else {
                    //  error occurred
                    let alert = UIAlertController(title: "Log In Error", message: "Unable to login", preferredStyle: .alert)
                    alert.addAction((UIAlertAction(title: "Dismss", style: .cancel, handler: nil)))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc private func didTapCreateAccountButton() {
        print("create account button tapped.")
        
        let vc = RegistrationViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.title = "Create Account"
        
        present(vc, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == usernameEmailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            didTapLoginButton()
        }
        return true
    }
}
