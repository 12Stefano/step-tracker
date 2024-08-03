//
//  WeightDiffBarChart.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 03/06/24.
//

import SwiftUI
import Charts


struct WeightDiffBarChart: View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?
    
    var chartData: [DateValueChartData]
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    
    var body: some View {
        let config = ChartContainerConfiguration(title: "Average weight change",
                                                 symbol: "figure",
                                                 subtitle: "Per weekday (last 28 days).",
                                                 context: .weight,
                                                 isNav: false)
        
        ChartContainerView(config: config) {
            
            if chartData.isEmpty {
                ChartEmptyView(systemImage: "chart.bar.xaxis", title: "No data", description: "There is no step data from healt app.")
                
            } else {
                Chart {
                    if let selectedData {
                        ChartAnnotationView(data: selectedData, context: .weight)
                    }
                    
                    ForEach(chartData) { weightDiff in
                        BarMark(x: .value("Date", weightDiff.date, unit: .day),
                                y: .value("weightDiff", weightDiff.value)
                        )
                        .foregroundStyle(weightDiff.value >= 0 ? Color.indigo.gradient : Color.mint.gradient)
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) {
                        AxisValueLabel(format: .dateTime.weekday(), centered: true)
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(Color.secondary.opacity(0.3))
                        
                        AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
                    }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: rawSelectedDate) { oldValue, newValue in
            if oldValue?.weekdayInt != newValue?.weekdayInt {
                selectedDay = newValue
            }
            
        }
    }
}

#Preview {
    WeightDiffBarChart(chartData: MockData.weightDiffs)
}
