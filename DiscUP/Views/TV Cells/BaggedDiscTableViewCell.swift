//
//  baggedDiscTableViewCell.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//

import UIKit

class BaggedDiscTableViewCell: UITableViewCell {

    //  MARK: - Properties
    var discName: String = "(disc name)"
    var discBrand: String = "(disc brand)"
    var discType: String = "(disc type)"
    var flightRatings: String = "[0][0][0][0]"
    
    var discNameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var discBrandLabel = UILabel()
    var discTypeLabel = UILabel()
    var flightRatinsLabel = UILabel()
    
    //  MARK: - LIFECYCLES
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupViews() {
        discBrandLabel.text = discBrand
    }
    
    
}
