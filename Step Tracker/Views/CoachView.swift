//
//  CoachView.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 11/10/25.
//

import SwiftUI

@available(iOS 26.0, *)
struct CoachView: View {
    @Environment(\.dismiss) var dismiss
    
    let analyzer = DataAnalyzer.shared
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "person")
                    .resizable()
                    .frame(width: 60, height: 60)
                
                Text("Fitness Coach")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Ok", systemImage: "checkmark") { dismiss() }
                    .padding()
                    .labelStyle(.iconOnly)
                    .clipShape(.circle)
                    .glassEffect(.regular.tint(.pink).interactive())
            }
            
            ScrollView {
                Text(analyzer.streamingMessage ?? "")
                    .contentTransition(.interpolate)
                    .animation(.easeInOut(duration: 0.8), value: analyzer.streamingMessage)
            }
            .overlay {
                if analyzer.isThinking {
                    VStack(spacing: 16) {
                        Image(systemName: "apple.intelligence")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .font(.largeTitle)
                            .symbolEffect(.pulse, options: .repeat(.continuous))
                        
                        Text("Thinking...")
                            .font(.callout)
                    }
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 200)
                }
            }
        }
        .padding(.top)
        .padding(.horizontal)
    }
}

@available(iOS 26.0, *)
#Preview {
    CoachView()
}
