//
//  HealthKitManager.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 29/05/24.
//

import Foundation
import HealthKit
import Observation

@Observable
class HealthKitManager {
    let store = HKHealthStore()
    
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
    
    var stepData: [HealthMetric] = []
    var weightData: [HealthMetric] = []
    var weightDiffData: [HealthMetric] = []
    
    func fetchStepCount() async {
        // Create a predicate for this week's samples.
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        // Last 28 days
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)!

        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate:queryPredicate)
        
        // Configure query
        let stepsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .cumulativeSum,
            anchorDate: endDate,
            intervalComponents: .init(day: 1))

        do {
            let stepCounts = try await stepsQuery.result(for: store)
            
            stepData = stepCounts.statistics().map {
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }
        } catch {
            
        }
    }
    
    func fetchWeignts() async {
        // Create a predicate for this week's samples.
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        // Last 28 days
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)!

        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate:queryPredicate)
        
        // Configure query
        let weightsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .mostRecent,
            anchorDate: endDate,
            intervalComponents: .init(day: 1))
        
        do {
            let weights = try await weightsQuery.result(for: store)
            
            weightData = weights.statistics().map {
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .gram()) ?? 0)
            }
        } catch {
            
        }
    }
    
    func fetchWeigntForDifferentials() async {
        // Create a predicate for this week's samples.
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        // Last 28 days
        let startDate = calendar.date(byAdding: .day, value: -29, to: endDate)!

        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate:queryPredicate)
        
        // Configure query
        let weightsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .mostRecent,
            anchorDate: endDate,
            intervalComponents: .init(day: 1))
        
        do {
            let weights = try await weightsQuery.result(for: store)
            
            weightDiffData = weights.statistics().map {
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .gram()) ?? 0)
            }
        } catch {
            
        }
    }
    
    func addStepData(for date: Date, value: Double) async {
        let stepQuantity = HKQuantity(unit: .count(), doubleValue: value)
        let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: date, end: date)
        
        try! await store.save(stepSample)
    }
    
    func addWeightData(for date: Date, value: Double) async {
        let weightQuantity = HKQuantity(unit: .gram(), doubleValue: value)
        let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuantity, start: date, end: date)
        
        try! await store.save(weightSample)
    }
    
//    Uncomment just to add mockup data on simulated device
//    func addSimulatorData() async {
//        var mockSamples: [HKQuantitySample] = []
//        
//        for i in 0..<28 {
//            let stepQuantity = HKQuantity(unit: .count(), doubleValue: .random(in: 4_000...20_000))
//            let weightQuantity = HKQuantity(unit: .gram(), doubleValue: .random(in: ((65 + Double(i/3))*1000...(70 + Double(i/3))*1000)))
//            let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
//            let endDate = Calendar.current.date(byAdding: .second, value: 1, to: startDate)!
//            
//            let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: startDate, end: endDate)
//            let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuantity, start: startDate, end: endDate)
//            
//            mockSamples.append(stepSample)
//            mockSamples.append(weightSample)
//        }
//        
//        try! await store.save(mockSamples)
//            
//        
//        print("✅ Dummy data sent up")
//    }
}
