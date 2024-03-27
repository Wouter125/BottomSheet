//
//  View+PresentationCornerRadius.swift
//
//
//  Created by Wouter van de Kamp on 30/01/2024.
//

import SwiftUI

extension View {
    public func presentationCornerRadiusPlus(
        cornerRadius: CGFloat?
    ) -> some View {
        return self.preference(
            key: SheetPlusPresentationCornerRadiusKey.self,
            value: cornerRadius
        )
    }
}
