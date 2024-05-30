//
//  Step_TrackerApp.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 28/05/24.
//

import SwiftUI

@main
struct Step_TrackerApp: App {
    
    let hkmanager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(hkmanager)
        }
    }
}
