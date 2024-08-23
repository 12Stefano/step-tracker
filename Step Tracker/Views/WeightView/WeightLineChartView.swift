//
//  WeightLineChartView.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 01/06/24.
//

import SwiftUI
import Charts


struct WeightLineChartView: View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?
    
    var chartData: [DateValueChartData]
    
    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    
    var averageWeight: Double {
        chartData.map {$0.value}.average/1_000
    }
    
    var body: some View {
        
        ChartContainerView(chartType: .weightLine(average: averageWeight)) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, context: .weight)
                }
                
                RuleMark(y: .value("Goal", 70_000))
                    .foregroundStyle(.mint)
                    .lineStyle(.init(lineWidth: 1, dash: [5]))
                    .accessibilityHidden(true)
                
                ForEach(chartData) { weight in
                    Plot {
                        AreaMark(
                            x: .value("Day", weight.date, unit: .day),
                            yStart: .value("Value", weight.value),
                            yEnd: .value("Min Value", minValue)
                        )
                        .foregroundStyle(Gradient(colors: [.indigo.opacity(0.5), .clear]))
                        
                        
                        LineMark(
                            x: .value("Day", weight.date, unit: .day),
                            y: .value("Value", weight.value)
                        )
                        .foregroundStyle(.indigo)
                        .interpolationMethod(.catmullRom)
                        .symbol(.circle)
                    }
                    .accessibilityLabel(weight.date.accessibilityDate)
                    .accessibilityValue("\(weight.value.formatted(.number.precision(.fractionLength(1)))) kg")
                }
            }
            .frame(height: 150)
            .chartXSelection(value: $rawSelectedDate)
            .chartYScale(domain:.automatic(includesZero: false))
            .chartXAxis {
                AxisMarks {
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    
                    AxisValueLabel("\((value.as(Double.self) ?? 0).formatted(.number.scale(0.001))) kg")
                }
            }
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(systemImage: "chart.xyaxis.line", title: "No data", description: "There is no step data from healt app.")
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
    WeightLineChartView(chartData: ChartHelper.convert(data: MockData.weights))
}
