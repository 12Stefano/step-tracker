//
//  ChartContainerView.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 05/08/24.
//

import SwiftUI

enum ChartType {
    case stepBar(average: Int)
    case stepWeekDayPie
    case weightLine(average: Double)
    case weightDiffBar
}

struct ChartContainerConfiguration {
    let title: String
    let symbol: String
    let subtitle: String
    let context: HealthMetricContext
    let isNav: Bool
    let accessibilityLabel: String
}


struct ChartContainerView<Content: View>: View {
    let chartType: ChartType
    
    var config: ChartContainerConfiguration {
        makeChartConfigurator(chartType: chartType)
    }
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading) {
            if config.isNav {
                navigationLinkView
            } else {
                titleView
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 12)
            }
            
            content()
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
    
    var navigationLinkView: some View {
        NavigationLink(value: config.context) {
            HStack {
                titleView
                
                Spacer()
                
                Image(systemName: "chevron.right")
            }
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 12)
        .accessibilityHint("Tap for data in list view.")
    }
    
    var titleView: some View {
        VStack(alignment: .leading) {
            Label(config.title, systemImage: config.symbol)
                .font(.title3.bold())
                .foregroundStyle(config.context == .steps ? .pink : .indigo)
            
            Text(config.subtitle)
                .font(.caption)
        }
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(config.accessibilityLabel)
        .accessibilityElement(children: .ignore)  // Elements inside VStak will not be read
    }
    
    private func makeChartConfigurator(chartType: ChartType) -> ChartContainerConfiguration {
        
        switch chartType {
        case .stepBar(let average):
            return ChartContainerConfiguration(title: "Steps",
                                               symbol: "figure.walk",
                                               subtitle: "Avg: \(average) steps.",
                                               context: .steps,
                                               isNav: true,
                                               accessibilityLabel: "Bar chart, step count, last 28 days, average steps per day: \(average) steps.")
            
            
        case .stepWeekDayPie:
            return ChartContainerConfiguration(title: "Averages",
                                               symbol: "calendar",
                                               subtitle: "Last 28 days.",
                                               context: .steps,
                                               isNav: false,
                                               accessibilityLabel: "Pie chart, average steps per weekday.")
            
        case .weightLine(let average):
            return ChartContainerConfiguration(title: "Weigt",
                                               symbol: "figure",
                                               subtitle: "Avg: \(average.formatted(.number.precision(.fractionLength(1)))) kg.",
                                               context: .weight,
                                               isNav: true,
                                               accessibilityLabel:"Line chart, weight, average weigt \(average.formatted(.number.precision(.fractionLength(1)))) kg, goal 70 kg.")
            
        case .weightDiffBar:
            return ChartContainerConfiguration(title: "Average weight change",
                                               symbol: "figure",
                                               subtitle: "Per weekday (last 28 days).",
                                               context: .weight,
                                               isNav: false,
                                               accessibilityLabel:"Bar chart, average weight difference per weekday.")
        }
    }
}

#Preview {
    ChartContainerView(chartType: .stepWeekDayPie) {
        Text("Chart")
            .frame(minHeight: 150)
    }
}
