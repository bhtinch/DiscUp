//
//  LogInRootView.swift
//  DiscUpV2
//
//  Created by Benjamin Tincher on 7/19/22.
//

import Foundation
import SwiftUI

struct LogInRootView: View {
    
    //  MARK: - Fields
    
    enum Field {
        case email
        case username
        case firstName
        case lastName
        case password
        case passwordConfirmation
        
        var placeholder: String {
            switch self {
            case .email: return "Email..."
            case .username: return "Username..."
            case .firstName: return "First Name... (Optional)"
            case .lastName: return "Last Name... (Optional)"
            case .password: return "Password..."
            case .passwordConfirmation: return "Confirm Password..."
            }
        }
    }
    
    // MARK: - Properties
    
    var viewModel: LogInViewModel
    
    @State var newUser: Bool = false
    
    var passwordsMatch: Bool {
        password == passwordConfirmation
    }
    
    let shadowColor = AppTheme.Colors.mainAccent.color
    
    var passwordShadowColor: Color {
        guard
            newUser,
            password != "" || passwordConfirmation != ""
        else { return shadowColor }
        
        return passwordsMatch ? .green : .red
    }
    
    var signUpSubmittable: Bool {
        newUser &&
        passwordsMatch &&
        password != "" &&
        email != "" &&
        username != ""
    }
    
    @State var email: String = ""
    @State var username: String = ""
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var password: String = ""
    @State var passwordConfirmation: String = ""
    
    @FocusState private var focusedField: Field?
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            TextField(Field.email.placeholder, text: $email)
                .focused($focusedField, equals: .email)
                .textInputAutocapitalization(.never)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .submitLabel(.next)
                .shadow(color: shadowColor, radius: 2, x: 0, y: 0)
            
            if newUser {
                TextField(Field.username.placeholder, text: $username, onEditingChanged: { _ in
                    viewModel.send(.didInputUsername(username))
                })
                    .focused($focusedField, equals: .username)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .submitLabel(.next)
                    .shadow(color: shadowColor, radius: 2, x: 0, y: 0)
                
                TextField(Field.firstName.placeholder, text: $firstName)
                    .focused($focusedField, equals: .firstName)
                    .textContentType(.name)
                    .keyboardType(.namePhonePad)
                    .submitLabel(.next)
                
                TextField(Field.lastName.placeholder, text: $lastName)
                    .focused($focusedField, equals: .lastName)
                    .textContentType(.familyName)
                    .keyboardType(.namePhonePad)
                    .submitLabel(.next)
            }
            
            SecureField(Field.password.placeholder, text: $password)
                .focused($focusedField, equals: .password)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .submitLabel(newUser ? .next : .go)
                .shadow(color: passwordShadowColor, radius: 2, x: 0, y: 0)
                                 
            
            if newUser {
                SecureField(Field.passwordConfirmation.placeholder, text: $passwordConfirmation)
                    .focused($focusedField, equals: .passwordConfirmation)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .submitLabel(.join)
                    .shadow(color: passwordShadowColor, radius: 2, x: 0, y: 0)
            }
            
            Button {
                newUser ?
                viewModel.send(.signUpWith(email, username, firstName, lastName, password)) :
                viewModel.send(.signInWith(email, password))
                
            } label: {
                Text(newUser ? "Sign Up" : "Sign In")
                    .frame(maxWidth: .infinity)
            }
            .tint(AppTheme.Colors.mainAccent.color)
            .buttonStyle(.borderedProminent)
            .disabled(newUser ? !signUpSubmittable : false)
            
            Button(newUser ? "Sign In" : "Register") {
                newUser.toggle()
            }
        }
        .textFieldStyle(.roundedBorder)
        .padding()
        
        .onSubmit {
            switch focusedField {
            case .email: focusedField = newUser ? .username : .password
            case .username: focusedField = .firstName
            case .firstName: focusedField = .lastName
            case .lastName: focusedField = .password
                
            case .password:
                newUser ?
                focusedField = .passwordConfirmation :
                viewModel.send(.signInWith(email, password))
                
            case .passwordConfirmation:
                signUpSubmittable ? viewModel.send(.signUpWith(email, username, firstName, lastName, password)) : debugPrint("")
            
            case .none:
                break
            }
        }
    }
}
