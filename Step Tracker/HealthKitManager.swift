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
}
