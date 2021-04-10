//
//  EventTableViewCell.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 4/10/21.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    //  MARK: - OUTLETS
    @IBOutlet weak var dateLabel: EventDateLabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var tierLabel: RoundedColorLabel!
    @IBOutlet weak var logoImage: UIImageView!
    
    //  MARK: - LIFECYCLE
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
