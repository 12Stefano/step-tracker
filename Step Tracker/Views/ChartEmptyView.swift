//
//  ChartEmptyView.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 03/08/24.
//

import SwiftUI

struct ChartEmptyView: View {
    let systemImage: String
    let title: String
    let description: String
    
    var body: some View {
        ContentUnavailableView {
            Image(systemName: systemImage)
                .resizable()
                .frame(width: 32, height: 32)
                .padding(.bottom, 8)
            
            Text(title)
                .font(.callout.bold())
            
            Text(description)
                .font(.footnote)
        }
        .foregroundStyle(.secondary)
    }
}

#Preview {
    ChartEmptyView(systemImage: "chart.bar", title: "No data", description: "There is no step data from healt app.")
}
