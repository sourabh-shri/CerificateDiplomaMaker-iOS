//
//  CustomYearLabel.swift
//  CerificatesTemplates
//
//  Created by SMT Sourabh  on 06/06/24.
//  Copyright © 2024 Mobiona. All rights reserved.
//

import UIKit

class CustomYearLabel: UILabel {
    
    //MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .red

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(. year, from: currentDate)
        text = "© " + currentYear.description
    }
    
    
}
