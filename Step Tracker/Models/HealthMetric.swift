//
//  HealthMetric.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 30/05/24.
//

import Foundation


struct HealthMetric: Identifiable {
    let id = UUID()
    
    let date: Date
    let value: Double

}
