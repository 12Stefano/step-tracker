//
//  DashboardView.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 28/05/24.
//

import SwiftUI
import Charts


enum HealthMetricContext: CaseIterable, Identifiable {
    var id: Self { self }
    
    case steps, weight
    
    var title: String {
        switch self {
        case .steps:
            return "Steps"
        case .weight:
            return "Weight"
        }
    }
}

struct DashboardView: View {
    @Environment(HealthKitManager.self) private var hkManager
    
    @State private var isShowingPermissionPrimingSheet = false
    @State private var selectedStat: HealthMetricContext = .steps
    @State private var isShowingAlert = false
    @State private var fetchError: STError = .noData
    
    var isSteps: Bool { selectedStat == .steps }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Selected Stat", selection: $selectedStat) {
                        ForEach(HealthMetricContext.allCases) { metric in
                            Text(metric.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    switch selectedStat {
                    case .steps:
                        StepBarChartView(chartData: ChartHelper.convert(data: hkManager.stepData))
                        
                        StepPieChartView(chartData: ChartMath.averageWeekdayCount(for: hkManager.stepData))
                    case .weight:
                        WeightLineChartView(chartData: ChartHelper.convert(data: hkManager.weightData))
                        
                        WeightDiffBarChart(chartData: ChartMath.averageDailyWeightDiffs(for: hkManager.weightDiffData))
                    }
                    
                }
                .padding()
                .task {
                    do {
                        try await hkManager.fetchStepCount()
                        try await hkManager.fetchWeignts()
                        try await hkManager.fetchWeigntForDifferentials()
                        
                    } catch STError.authNotDetermined {
                        isShowingPermissionPrimingSheet = true
                    } catch STError.noData {
                        fetchError = .noData
                        isShowingAlert = true
                    } catch {
                        fetchError = .unableToCompleteRequest
                        isShowingAlert = true
                    }
                }
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionPrimingSheet, onDismiss: {
                // Fetch health data
            }, content: {
                HealthKitPermissionPrimingView()
            })
            .alert(isPresented: $isShowingAlert, error: fetchError) { fetchError in
                // Action
            } message: { fetchError in
                Text(fetchError.failureReason)
            }
        }
        .tint(isSteps ? .pink : .indigo)
    }
    
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
