//
//  DataAnalyzer.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 10/10/25.
//

import Foundation
import FoundationModels
import Playgrounds

@available(iOS 26, *)
@Observable
final class DataAnalyzer {
    static let shared = DataAnalyzer()
    let model: SystemLanguageModel = .default
    
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
