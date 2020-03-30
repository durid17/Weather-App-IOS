//
//  cell.swift
//  weather_durid
//
//  Created by GEOLAB TRAININGS on 2/18/20.
//  Copyright © 2020 GEOLAB TRAININGS. All rights reserved.
//

import UIKit

class cell: UITableViewCell {
    
    @IBOutlet weak var Temperature: UILabel!
    @IBOutlet weak var Time: UILabel!
    @IBOutlet weak var Weather: UIImageView!
    @IBOutlet weak var Description: UILabel!
    
    func configure(from model: CellModel) {
        Temperature.text = model.temp
        Time.text = model.hour
        Description.text = model.description
        Weather.image = model.image
    }
    
}
