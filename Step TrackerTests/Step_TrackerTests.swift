//
//  Step_TrackerTests.swift
//  Step TrackerTests
//
//  Created by Stefano Pozzi on 29/10/24.
//

import Testing
import Foundation
@testable import Step_Tracker

struct Step_TrackerTests {
    
    @Test
    func arrayAverage() {
        let array: [Double] = [2.0, 3.1, 0.45, 1.84]
        
        #expect(array.average == 1.8475)
    }
    
}


@Suite("Chart Helpers Tests")
struct ChartHelpersTests {
    
    var metrics: [HealthMetric] = [
        .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day: 14))!, value: 1000),
        .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day: 15))!, value: 500),
        .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day: 16))!, value: 250),
        .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day: 21))!, value: 750),
    ]
    
    @Test
    func averageWeekdayCount() {
        let averageWeekdayCount = ChartHelper.averageWeekdayCount(for: metrics)
        
        #expect(averageWeekdayCount.count == 3)
        #expect(averageWeekdayCount[0].value == 875.0)
        #expect(averageWeekdayCount[1].value == 500.0)
        #expect(averageWeekdayCount[2].date.weekdayTitle == "Wednesday")
        
    }
}
