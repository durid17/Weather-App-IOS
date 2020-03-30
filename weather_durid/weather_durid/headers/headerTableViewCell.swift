//
//  headerTableViewCell.swift
//  weather_durid
//
//  Created by GEOLAB TRAININGS on 2/18/20.
//  Copyright © 2020 GEOLAB TRAININGS. All rights reserved.
//

import UIKit

class headerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var WeekDay: UILabel!
    
    func configure(from model: HeaderModel) {
        WeekDay.text = model.weekDay
    }
    
}
