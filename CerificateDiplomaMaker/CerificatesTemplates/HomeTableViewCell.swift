//
//  HomeTableViewCell.swift
//  CerificatesTemplates
//
//  Created by Bhisma on 11/8/16.
//  Copyright © 2016 Mobiona. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var dateOfIssue: UILabel!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor.clear
        deleteBtn.isSelected = false
    }
}
