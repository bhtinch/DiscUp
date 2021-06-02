//
//  UIClasses.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 4/10/21.
//

import Foundation
import UIKit

class RoundedColorLabel: UILabel {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4
        self.textColor = .white
    }
}

class EventDateLabel: RoundedColorLabel {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .systemIndigo
    }
}

