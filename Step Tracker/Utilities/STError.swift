//
//  STError.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 06/08/24.
//

import Foundation


enum STError: LocalizedError {
    case authNotDetermined
    case sharingDenied(quantityType: String)
    case noData
    case unableToCompleteRequest
    case invalidValue
    
    var errorDescription: String? {
        switch self {
        case .authNotDetermined:
            "Need Access to healt data"
        case .sharingDenied(_):
            "No write access"
        case .noData:
            "No data"
        case .unableToCompleteRequest:
            "Unable to complete request"
        case .invalidValue:
            "Invalid value"
        }
    }
    
    var failureReason: String {
        switch self {
        case .authNotDetermined:
            "You have no given access to your healt data.\n\nPlease go to Settings > Healt > Data access & Devices."
        case .sharingDenied(let quantityType):
            "You have denied the access to upload your \(quantityType) data.\n\nYou can change this in Settings > Healt > Data access & Devices."
        case .noData:
            "There is no data for this healt statistics"
        case .unableToCompleteRequest:
            "We are unable to complete your request at this time.\n\nPlase try again later or contact support."
        case .invalidValue:
            "Must be a numeric value."
        }
    }
    
}
