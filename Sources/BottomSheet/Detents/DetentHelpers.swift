//
//  File.swift
//  
//
//  Created by Wouter van de Kamp on 20/11/2022.
//

import SwiftUI

/// Computes the limits of how far the sheet can move.
/// - Parameter detents: The list of detents provided when initializing the bottomsheet
/// - Returns: Tuple with top and bottom. Top reflects the offset from the top of the screen when the sheet is in it's largest form. Bottom reflects the offset from the top of the screen when the sheet is in it's smallest form.
func detentLimits(detents: Set<PresentationDetent>) -> (min: CGFloat, max: CGFloat) {
    let detentLimits: [CGFloat] = detents
        .map { detent in
            switch detent {
            case .small:
                return PresentationDetentDefaults.small
            case .medium:
                return PresentationDetentDefaults.medium
            case .large:
                return PresentationDetentDefaults.large
            case .fraction(let fraction):
                return (UIScreen.main.bounds.height - (ScreenSize.topInset ?? 0)) * fraction
            case .height(let height):
                return height
            }
        }
        .sorted(by: <)
    
    return (min: detentLimits.first ?? 0, max: detentLimits.last ?? 0)
}
