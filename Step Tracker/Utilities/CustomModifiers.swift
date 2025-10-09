//
//  CustomModifiers.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 09/10/25.
//

import SwiftUI

struct ProminentButton: ViewModifier {
    
    var color: Color
    
    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, *) {
            content
                .buttonStyle(.glassProminent)
                .tint(color)
        } else {
            content
                .buttonStyle(.borderedProminent)
                .tint(color)
        }
    }
}

