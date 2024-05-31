//
//  StepPieChartView.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 31/05/24.
//

import SwiftUI
import Charts


struct StepPieChartView: View {
    var chartData: [WeekdayChartData] = []
    
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
            
            Chart {
                ForEach(chartData) { weekday in
                    SectorMark(angle: .value("Average steps", weekday.value), 
                               innerRadius: .ratio(0.618),
                               angularInset: 1)
                    .foregroundStyle(.pink)
                    .cornerRadius(6)
                }
            }
            .frame(height: 240)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))    }
}

#Preview {
    StepPieChartView(chartData: ChartMath.averageWeekdayCount(for: HealthMetric.mockData))
}
