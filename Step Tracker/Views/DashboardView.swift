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
    @Environment(HealthKitData.self) private var hkData
    
    @Namespace var zoomTransition
    
    @State private var isShowingPermissionPrimingSheet = false
    @State private var selectedStat: HealthMetricContext = .steps
    @State private var isShowingAlert = false
    @State private var fetchError: STError = .noData
    @State private var isShowingCoachView: Bool = false
    
    var metricColor: Color {
        selectedStat == .steps ? .pink : .indigo
    }
    
    var navbarTint: Color {
        if #available(iOS 26, macOS 26, *) {
            return .primary
        } else {
            return metricColor
        }
    }
    
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
                        StepBarChartView(chartData: ChartHelper.convert(data: hkData.stepData))
                        
                        StepPieChartView(chartData: ChartHelper.averageWeekdayCount(for: hkData.stepData))
                    case .weight:
                        WeightLineChartView(chartData: ChartHelper.convert(data: hkData.weightData))
                        
                        WeightDiffBarChart(chartData: ChartHelper.averageDailyWeightDiffs(for: hkData.weightDiffData))
                    }
                    
                }
                .padding()
            }
            .task { fetchHealtData() }
            .navigationTitle("Dashboard")
            .toolbarTitleDisplayMode(.inlineLarge)
            .background(LinearGradient(colors: [metricColor.opacity(0.25), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
            .toolbar {
                if #available(iOS 26, macOS 26, *) {
                    if DataAnalyzer.shared.isAvailable {
                        ToolbarItem {
                            Button("Analyze data", systemImage: "apple.intelligence") {
                                isShowingCoachView.toggle()
                                Task { await DataAnalyzer.shared.analyzeHealthData() }
                            }
                        }
                        .matchedTransitionSource(id: "coachView", in: zoomTransition)
                    }
                }
            }
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .fullScreenCover(isPresented: $isShowingPermissionPrimingSheet, onDismiss: {
                fetchHealtData()
            }, content: {
                HealthKitPermissionPrimingView()
            })
            .backportSheet(isPresented: $isShowingCoachView, namespace: zoomTransition)
            .alert(isPresented: $isShowingAlert, error: fetchError) { fetchError in
                // Action
            } message: { fetchError in
                Text(fetchError.failureReason)
            }
        }
        .tint(navbarTint)
    }
    
    private func fetchHealtData() {
        Task{
            do {
                async let steps = hkManager.fetchStepCount()
                async let weightsForLineChart = hkManager.fetchWeignts(daysBack: 28)
                async let weightsForDiffBarChart = hkManager.fetchWeignts(daysBack: 29)
                
                hkData.stepData = try await steps
                hkData.weightData = try await weightsForLineChart
                hkData.weightDiffData = try await weightsForDiffBarChart
                
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
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
        .environment(HealthKitData())
}
