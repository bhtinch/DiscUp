//
//  SpinnerView.swift
//  intel
//
//  Created by Ben Tincher on 12/22/21.
//

import UIKit

// MARK: - HasSpinner Protocol

protocol HasSpinner: UIViewController {
    var spinner: SpinnerView { get }
}

extension HasSpinner {
    var spinner: SpinnerView {
        let spinner = SpinnerView()
        
        view.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return spinner
    }
}

// MARK: - SpinnerView

class SpinnerView: UIActivityIndicatorView {
    
    // MARK: - Initialization
    
    override init(style: UIActivityIndicatorView.Style = .large) {
        super.init(style: style)
        translatesAutoresizingMaskIntoConstraints = false
        
        color = .systemIndigo
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Methods

extension SpinnerView {
    func animate(_ animate: Bool) {
        animate ? startAnimating() : stopAnimating()
    }
}
