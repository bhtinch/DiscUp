//
//  Alerts.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/20/21.
//

import Foundation
import UIKit

class Alerts: UIViewController {
    enum Common: LocalizedError {
        case noCurrentUser
        
        var title: String {
            switch self {
            default: "An error occurred."
            }
        }
        
        var message: String? {
            switch self {
            case .noCurrentUser: "Error: Unknown user.\nPlease try logging out and logging back in."
            }
        }
    }
    
    static func presentCommonAlert(_ alert: Alerts.Common, sender: UIViewController) {
        presentAlertWith(title: alert.title, message: alert.message, sender: sender)
    }
    
    static func presentAlertWith(title: String, message: String?, sender: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        DispatchQueue.main.async {
            sender.present(alert, animated: true, completion: nil)
        }
    }
    
    static func presentActionSheetWith(title: String, message: String?, sender: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        DispatchQueue.main.async {
            sender.present(alert, animated: true, completion: nil)
        }
    }
}

class AlertService {
    static func showAlert(
        style: UIAlertController.Style,
        title: String?,
        message: String?,
        actions: [UIAlertAction] = [UIAlertAction(title: "Ok", style: .cancel, handler: nil)],
        completion: (() -> Swift.Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        for action in actions {
            alert.addAction(action)
        }
        
        UIApplication.shared.delegate?.window??.rootViewController?.present(alert, animated: true, completion: completion)
    }
}
