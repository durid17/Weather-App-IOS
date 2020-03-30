//
//  stackViewExtension.swift
//  weather_durid
//
//  Created by GEOLAB TRAININGS on 2/18/20.
//  Copyright © 2020 GEOLAB TRAININGS. All rights reserved.
//

import UIKit

extension UIStackView {
    func addHorizontalSeparators(color : UIColor) {
        var i = self.arrangedSubviews.count - 1
        while i >= 1{
            let separator = createSeparator(color: color)
            insertArrangedSubview(separator, at: i)
            separator.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
            i -= 1
        }
    }

    private func createSeparator(color : UIColor) -> UIView {
        let separator = UIView()
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.backgroundColor = color
        return separator
    }

    func addVerticalSeparators(color : UIColor) {
        var i = self.arrangedSubviews.count - 1
        while i >= 1 {
            let separator = createSeparatorVertical(color: color)
            insertArrangedSubview(separator, at: i)
            separator.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5).isActive = true
            i -= 1
        }
    }

    private func createSeparatorVertical(color : UIColor) -> UIView {
        let separator = UIView()
        separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        separator.backgroundColor = color
        return separator
    }
}
