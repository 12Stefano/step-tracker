//
//  View+Extensions.swift
//  Step Tracker
//
//  Created by Stefano Pozzi on 09/10/25.
//

import SwiftUI

extension View {
    func prominentButton(color: Color) -> some View {
        modifier(ProminentButton(color: color))
    }
}
