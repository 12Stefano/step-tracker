//
//  HealthDataListView.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 29/05/24.
//

import SwiftUI

struct HealthDataListView: View {
    @Environment(HealthKitManager.self) private var hkManager
    @Environment(HealthKitData.self) private var hkData
    
    @Namespace var zoomTransition
    
    @State private var isShowingAddData: Bool = false
    @State private var addDataDate: Date = .now
    @State private var valueToAdd: String = ""
    @State private var isShowingAlert = false
    @State private var writeError: STError = .noData
    
    var metric: HealthMetricContext
    
    var listData: [HealthMetric] {
        metric == .steps ? hkData.stepData : hkData.weightData
    }
    
    var metricColor: Color {
        metric == .steps ? .pink : .indigo
    }
    
    var body: some View {
        List(listData.reversed()) { data in
            LabeledContent {
                Text(data.value, format: .number.precision(.fractionLength(metric == .steps ? 0 : 1)))
            } label: {
                Text(data.date, format: .dateTime.month().day().year())
                    .accessibilityLabel(data.date.accessibilityDate)
            }
            .listRowBackground(Color(.secondarySystemBackground).opacity(0.35))
            .accessibilityElement(children: .combine)
        }
        .navigationTitle(metric.title)
        .scrollContentBackground(.hidden)
        .background(LinearGradient(colors: [metricColor.opacity(0.25), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
        
        .sheet(isPresented: $isShowingAddData) {
            if #available(iOS 26, macOS 26, *) {
                addDataView
                    .presentationDetents([.fraction(0.4)])
                    .scrollContentBackground(.hidden)
                    .navigationTransition(.zoom(sourceID: "addData", in: zoomTransition))
            } else {
                addDataView
                    .presentationDetents([.fraction(0.4)])
            }
        }
        .overlay {
            if listData.isEmpty {
                ContentUnavailableView("No \(metric.title) to display", systemImage: metric == .steps ? "figure.walk" : "figure")
            }
        }
        .toolbar{
                if #available(iOS 26, macOS 26, *) {
                    ToolbarItem {
                        Button("Add Data", systemImage: "plus") {
                            isShowingAddData = true
                        }
                        .buttonStyle(.glassProminent)
                        .tint(metricColor)
                    }
                    .matchedTransitionSource(id: "addData", in: zoomTransition)
                } else {
                    ToolbarItem {
                    Button("Add Data", systemImage: "plus") {
                        isShowingAddData = true
                    }
                }
            }
        }
    }
    
    var addDataView: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $addDataDate, displayedComponents: .date)
                
                LabeledContent(metric.title) {
                    TextField("Value", text: $valueToAdd)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 140)
                        .keyboardType(metric == .steps ? .numberPad : .decimalPad)
                }
                
            }
            .navigationTitle("Add new")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $isShowingAlert, error: writeError) { writeError in
                // Action
                switch writeError {
                case .authNotDetermined, .noData, .unableToCompleteRequest, .invalidValue:
                    EmptyView()
                case .sharingDenied(_):
                    Button("Settings") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    Button("Cancel", role: .cancel) { }
                }
            } message: { writeError in
                Text(writeError.failureReason)
            }
            
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    if #available(iOS 26, macOS 26, *) {
                        Button("Add data", role: .confirm) { addDataToHealtKit() }
                            .tint(metricColor)
                    } else {
                        Button("Add data") { addDataToHealtKit() }
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    if #available(iOS 26, macOS 26, *) {
                        Button("Dismiss", role: .close) { isShowingAddData = false }
                    } else {
                        Button("Dismiss") { isShowingAddData = false }
                    }
                    
                }
            }
        }
    }
    
    private func addDataToHealtKit() {
        guard let value = Double(valueToAdd) else {
            writeError = .invalidValue
            isShowingAlert = true
            valueToAdd = ""
            return
        }
        
        Task{
            
            do {
                if metric == .steps {
                    try await hkManager.addStepData(for: addDataDate, value: value)
                    
                    hkData.stepData = try await hkManager.fetchStepCount()
                } else {
                    try await hkManager.addWeightData(for: addDataDate, value: value)
                    
                    async let weightsForLineChart = hkManager.fetchWeignts(daysBack: 28)
                    async let weightsForDiffBarChart = hkManager.fetchWeignts(daysBack: 29)
                    
                    hkData.weightData = try await weightsForLineChart
                    hkData.weightDiffData = try await weightsForDiffBarChart
                }
                
                isShowingAddData = false
                
            } catch STError.sharingDenied(let quantityType) {
                writeError = .sharingDenied(quantityType: quantityType)
                isShowingAlert = true
                
            } catch {
                writeError = .unableToCompleteRequest
                isShowingAlert = true
            }
        }
    }
}

#Preview {
    NavigationStack{
        HealthDataListView(metric: .weight)
            .environment(HealthKitManager())
            .environment(HealthKitData())
    }
}
