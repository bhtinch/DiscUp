//
//  SwitchBagTableViewCell.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/5/21.
//

import UIKit

protocol SwitchBagTableViewCellDelegate: AnyObject {
    func callSegue(bagID: String)
}

class SwitchBagTableViewCell: UITableViewCell {
    //  MARK: - OUTLETS
    @IBOutlet weak var bagNameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    //  MARK: - PROPTERTIES
    weak var delegate: SwitchBagTableViewCellDelegate?
    var bagID: String?
    
    //  MARK: - ACTIONS
    @IBAction func editButtonTapped(_ sender: Any) {
        guard let bagID = bagID else { return }
        delegate?.callSegue(bagID: bagID)
    }
}
