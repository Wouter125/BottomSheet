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
        return self.preference(
            key: SheetPlusBackgroundInteractionKey.self,
            value: interaction
        )
    }
}
