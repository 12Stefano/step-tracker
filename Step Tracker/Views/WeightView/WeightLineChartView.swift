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
    
    var selectedStat: HealthMetricContext
    var chartData: [HealthMetric]
    
    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }
    
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        
        return chartData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
    
    var body: some View {
        VStack {
            NavigationLink(value: selectedStat) {
                HStack {
                    VStack(alignment: .leading) {
                        Label("Weigt", systemImage: "figure")
                            .font(.title3.bold())
                            .foregroundStyle(.indigo)
                        
                        Text("Avg:  70 kg")
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                }
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 12)
            
            Chart {
                if let selectedHealthMetric {
                    RuleMark(x: .value("Selected Metric", selectedHealthMetric.date, unit: .day))
                        .foregroundStyle(Color.secondary.opacity(0.3))
                        .offset(y: -10)
                        .annotation(position: .top,
                                    spacing: 0,
                                    overflowResolution: .init(x: .fit(to: .chart),y: .disabled)) {
                            AnnotationView
                        }
                }
                
                RuleMark(y: .value("Goal", 70_000))
                    .foregroundStyle(.mint)
                    .lineStyle(.init(lineWidth: 1, dash: [5]))
                
                ForEach(chartData) { weight in
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
                    
                    AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.scale(0.001)))
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
    
    var AnnotationView: some View {
        VStack(alignment: .leading) {
            Text(selectedHealthMetric?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated))
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(1)))
                .fontWeight(.heavy)
                .foregroundStyle(.indigo)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemBackground))
                .shadow(color:.secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        }
    }
}

#Preview {
    WeightLineChartView(selectedStat: .weight, chartData: MockData.weights)
}
