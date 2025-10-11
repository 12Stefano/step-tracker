//
//  DataAnalyzer.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 10/10/25.
//

import Foundation
import FoundationModels
import Playgrounds

@available(iOS 26.0, *)
@Observable
final class DataAnalyzer {
    static let shared = DataAnalyzer()
    let model: SystemLanguageModel = .default
    var isThinking: Bool = false
    var streamingMessage: String.PartiallyGenerated?
    
    // TODO: Implement different unavailable messages
    var isAvailable: Bool {
        switch model.availability {
        case .available:
            return true
        case .unavailable(.appleIntelligenceNotEnabled):
            return false
        case .unavailable(.deviceNotEligible):
            return false
        case .unavailable(.modelNotReady):
            return false
        case .unavailable(_):
            return false
        }
    }
    
    private init() {}
    
    func analyzeHealthData() async {
        isThinking = true
        let session = LanguageModelSession(tools: [HealthDataTool()],
                                           instructions: "You are a high-energy motivational fitness coach. You love to analyze step and weight data to surface valuable insights and motivate people along their fitness journeys and help them with their fitness goals."
        )
        
        let prompt = """
            Use the `fetchStepsAndWeight` tool to get stats about the user’s recent step count and weight in kilograms. 
            Each stat is labeled with a value such as `stepsTotal: value`. The `numberOfStepsDays` stat represents how many 
            days are in the steps dataset and the `numberOfWeightDays` stat represents how many             
            days are in the weight dataset.

            Use these stats to share interesting insights with the user about their weight and step count data. Always 
            mention their highest step count day to highlight an achievement. Always mention the total weight lost or 
            gained and provide encouragement along with some healthy tips about weight loss.

            The output should be 2 to 3 short paragraphs, human readable, and easy to digest. It should read as if a fitness 
            coach is talking to the user and cheering on their fitness journey. Focus mostly on data and insights 
            with a touch of motivational language. Only use an emoji after the final line of your response.
            """
        
        do {
            let stream = session.streamResponse(to: prompt)
            for try await partial in stream {
                isThinking = false
                if partial.content != "null" {
                    streamingMessage = partial.content
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

@available(iOS 26.0, *)
struct HealthDataTool: Tool {
    var name: String = "fetchStepsAndWeight"
    var description: String = "Fetch user's recent step count and weight data from HealthKit."
    
    
    @Generable()
    struct Arguments { }
    
    func call(arguments: Arguments) async throws -> String {
        let hkManager = HealthKitManager()
        let steps = try await hkManager.fetchStepCount().map { $0.value }
        let weights = try await hkManager.fetchWeignts(daysBack: 28).map { $0.value }
        
        let stepsHight = Int(steps.max() ?? 0)
        let stepsLow = Int(steps.min() ?? 0)
        let stepsTotal = Int(steps.reduce(0, +))
        let stepsAvg = Int( Double(stepsTotal) / Double(steps.count).rounded(.up) )
        
        
        let weightHight = Int(weights.max() ?? 0)
        let weightLow = Int(weights.min() ?? 0)
        let overallWeightDiff = weights.first ?? 0 - (weights.last ?? 0)
        
        return """
            stepsHighestValue: \(stepsHight),
            stepsLowestValue: \(stepsLow),
            stepsTotal: \(stepsTotal),
            stepsAvg: \(stepsAvg),
            weightHighestValue: \(weightHight),
            weightLowestValue: \(weightLow),
            overallWeightDiff: \(overallWeightDiff),
            numberOfStepsDays: \(steps.count),
            numberOfWeightDays: \(weights.count),
            """
        
    }
    
}


//@available(iOS 26, *)
//#Playground {
//    let session = LanguageModelSession()
//    let prompt = "What are the best cities to view in Italy?"
//
//    do {
//        let response = try await session.respond(to: prompt)
//        print(response.content)
//    } catch {
//        print(error)
//    }
//}
