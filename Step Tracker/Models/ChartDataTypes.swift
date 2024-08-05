//
//  ChartDataTypes.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 31/05/24.
//

import Foundation


struct DateValueChartData: Identifiable, Equatable {
    let id = UUID()
    
    let date: Date
    let value: Double
}
