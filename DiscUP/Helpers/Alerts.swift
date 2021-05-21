//
//  Alerts.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/20/21.
//

import Foundation
import UIKit

class Alerts: UIViewController {
    
    static func presentAlertWith(title: String, message: String?, sender: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        sender.present(alert, animated: true, completion: nil)
    }
}
