//
//  spinner.swift
//  weather_durid
//
//  Created by GEOLAB TRAININGS on 2/18/20.
//  Copyright © 2020 GEOLAB TRAININGS. All rights reserved.
//

import UIKit


func showSpinner(onView : UIView) {
    if(vSpinner != nil) {return}
    let spinnerView = UIView.init(frame: onView.bounds)
    spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.99)
    let ai = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.large)
    ai.startAnimating()
    ai.center = spinnerView.center
    
    DispatchQueue.main.async {
        spinnerView.addSubview(ai)
        onView.addSubview(spinnerView)
    }
    
    vSpinner = spinnerView
}

func removeSpinner() {
    if(self.vSpinner == nil) {return}
    DispatchQueue.main.async {
        self.vSpinner?.removeFromSuperview()
        self.vSpinner = nil
    }
}
