//
//  StepPieChartView.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 31/05/24.
//

import SwiftUI
import Charts


struct StepPieChartView: View {
    @State private var rawSelectedChartValue: Double?
    @State private var selectedDay: Date?
    
    var chartData: [WeekdayChartData] = []
    
    var selectedWeekday: WeekdayChartData? {
        guard let rawSelectedChartValue else { return nil }
        var total = 0.0
        return chartData.first {
            total += $0.value
            return rawSelectedChartValue <= total
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Label("Averages", systemImage: "calendar")
                    .font(.title3.bold())
                    .foregroundStyle(.pink)
                
                Text("Last 28 days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 12)
            
            if chartData.isEmpty {
                ChartEmptyView(systemImage: "chart.pie", title: "No data", description: "There is no step data from healt app.")
            
            } else {
                Chart {
                    ForEach(chartData) { weekday in
                        SectorMark(angle: .value("Average steps", weekday.value),
                                   innerRadius: .ratio(0.618),
                                   outerRadius: selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 140 : 110,
                                   angularInset: 1)
                        .foregroundStyle(.pink)
                        .cornerRadius(6)
                        .opacity(selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 1.0 : 0.3)
                    }
                }
                .chartAngleSelection(value: $rawSelectedChartValue.animation(.easeInOut))
                .frame(height: 240)
                .chartBackground { proxy in
                    GeometryReader { geo in
                        if let plotFrame = proxy.plotFrame {
                            let frame = geo[plotFrame]
                            if let selectedWeekday {
                                VStack {
                                    Text(selectedWeekday.date.weekdayTitle)
                                        .font(.title3.bold())
                                        .contentTransition(.identity)
                                    
                                    Text(selectedWeekday.value, format: .number.precision(.fractionLength(0)))
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondary)
                                        .contentTransition(.numericText())
                                }
                                .position(x: frame.midX, y: frame.midY)
                            } else {
                                Image(systemName: "hand.tap")
                                    .font(.title3.bold())
                                    .contentTransition(.identity)
                                    .position(x: frame.midX, y: frame.midY)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: selectedWeekday) { oldValue, newValue in
            guard let oldValue, let newValue else { return }
            if oldValue.date.weekdayInt != newValue.date.weekdayInt {
                selectedDay = newValue.date
            }
            
        }
    }
}

#Preview {
    StepPieChartView(chartData: ChartMath.averageWeekdayCount(for: MockData.steps))
}
