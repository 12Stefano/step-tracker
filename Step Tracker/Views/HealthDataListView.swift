//
//  HealthDataListView.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 29/05/24.
//

import SwiftUI

struct HealthDataListView: View {
    @Environment(HealthKitManager.self) private var hkManager
    
    @State private var isShowingAddData: Bool = false
    @State private var addDataDate: Date = .now
    @State private var valueToAdd: String = ""
    
    @Binding var isShowingPermissionPriming: Bool
    
    var metric: HealthMetricContext
    
    var listData: [HealthMetric] {
        metric == .steps ? hkManager.stepData : hkManager.weightData
    }
    
    var body: some View {
        List(listData.reversed()) { data in
            HStack {
                Text(data.date, format: .dateTime.month().day().year())
                
                Spacer()
                
                Text(data.value, format: .number.precision(.fractionLength(metric == .steps ? 0 : 1)))
            }
        }
        .navigationTitle(metric.title)
        
        .sheet(isPresented: $isShowingAddData) {
            addDataView
        }
        .toolbar{
            Button("Add Data", systemImage: "plus") {
                isShowingAddData = true
            }
        }
    }
    
    var addDataView: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $addDataDate, displayedComponents: .date)
                
                HStack {
                    Text(metric.title)
                    Spacer()
                    TextField("Value", text: $valueToAdd)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 140)
                        .keyboardType(metric == .steps ? .numberPad : .decimalPad)
                }
            }
            .navigationTitle(metric.title)
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add data") {
                        Task{
                            if metric == .steps {
                                do {
                                    try await hkManager.addStepData(for: addDataDate, value: Double(valueToAdd)!)
                                    try await hkManager.fetchStepCount()
                                    
                                    isShowingAddData = false
                                    
                                } catch STError.authNotDetermined {
                                    isShowingPermissionPriming = true
                                    
                                } catch STError.sharingDenied(let quantityType) {
                                    print("❌ Sharing denied for \(quantityType)")
                                    
                                } catch {
                                    print("❌ Data list view unable to complete request")
                                }
                                
                            } else if metric == .weight {
                                do {
                                    try await hkManager.addWeightData(for: addDataDate, value: Double(valueToAdd)!)
                                    try await hkManager.fetchWeignts()
                                    try await hkManager.fetchWeigntForDifferentials()
                                    
                                    isShowingAddData = false
                                    
                                } catch STError.authNotDetermined {
                                    isShowingPermissionPriming = true
                                    
                                } catch STError.sharingDenied(let quantityType) {
                                    print("❌ Sharing denied for \(quantityType)")
                                    
                                } catch {
                                    print("❌ Data list view unable to complete request")
                                }
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss") {
                        isShowingAddData = false
                    }
                }
            }
        }
    }
    
}

#Preview {
    NavigationStack{
        HealthDataListView(isShowingPermissionPriming: .constant(false), metric: .weight)
            .environment(HealthKitManager())
    }
}
