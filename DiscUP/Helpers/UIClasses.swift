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

enum Tier: String, Codable {
    case L = "L"
    case NT = "NT"
    case B = "B"
    case C = "C"
    case M = "M"
    case A = "A"
    case DGPT = "DGPT"
    case XM = "XM"
    case XA = "XA"
    case XB = "XB"
    case XC = "XC"
}

