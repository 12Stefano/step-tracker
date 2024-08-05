//
//  ChartContainerView.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 05/08/24.
//

import SwiftUI


struct ChartContainerConfiguration {
    let title: String
    let symbol: String
    let subtitle: String
    let context: HealthMetricContext
    let isNav: Bool
}


struct ChartContainerView<Content: View>: View {
    let config: ChartContainerConfiguration

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
    }
    
    var titleView: some View {
        VStack(alignment: .leading) {
            Label(config.title, systemImage: config.symbol)
                .font(.title3.bold())
                .foregroundStyle(config.context == .steps ? .pink : .indigo)
            
            Text(config.subtitle)
                .font(.caption)
        }
    }
    
}

#Preview {
    ChartContainerView(config: .init(title: "Title", symbol: "figure.walk", subtitle: "Subtitle", context: .steps, isNav: true)) {
        Text("Chart")
            .frame(minHeight: 150)
    }
}
