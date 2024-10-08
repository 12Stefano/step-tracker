//
//  MockData.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 01/06/24.
//

import Foundation


struct MockData {
    static var steps: [HealthMetric] {
        var array: [HealthMetric] = []
        
        for i in 0..<28 {
            let metric = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!, value: .random(in: 4_000...20_000))
            
            array.append(metric)
        }
        
        return array
    }
    
    static var weights: [HealthMetric] {
        var array: [HealthMetric] = []
        
        for i in 0..<28 {
            let metric = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!, value: .random(in: ((65 + Double(i/3))*1000...(70 + Double(i/3))*1000)))
            
            array.append(metric)
        }
        
        return array
    }
    
    static var weightDiffs: [DateValueChartData] {
        var diffs: [DateValueChartData] = []
        
        for i in 0..<7 {
            let metric = DateValueChartData(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!, value: .random(in: -5...5)*1_000)
            
            diffs.append(metric)
        }
        
        return diffs
    }
}
