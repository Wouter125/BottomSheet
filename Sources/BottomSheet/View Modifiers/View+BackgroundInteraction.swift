//
//  View+BackgroundInteraction.swift
//  
//
//  Created by Wouter van de Kamp on 29/10/2023.
//

import SwiftUI

extension View {
    public func presentationBackgroundInteractionPlus(
        _ interaction: PresentationBackgroundInteractionPlus
    ) -> some View {
        return transformPreference(SheetPlusBackgroundInteractionKey.self) { value in
            switch interaction.kind {
                case .automatic:
                    value = nil
                case .disabled:
                    value = 0
                case .enabled(let detent):
                    value = detent?.size ?? 0
            }
        }
    }
}
