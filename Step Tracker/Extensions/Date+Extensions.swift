//
//  Date+Extensions.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 31/05/24.
//

import Foundation


extension Date {
    var weekdayInt: Int {
        Calendar.current.component(.weekday, from: self)
    }
}
