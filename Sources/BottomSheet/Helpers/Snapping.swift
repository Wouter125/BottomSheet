//
//  File.swift
//  
//
//  Created by Wouter van de Kamp on 20/11/2022.
//

import Foundation

/// Helper function that computes where the bottomsheet should snap to
/// - Parameters:
///   - translation: the current translated distance
///   - detents: the detents the translation can snap to
///   - yVelocity: the speed at which the drag gesture ended. Used to compute a snapping behaviour
/// - Returns: The snapping position distance
func snapBottomSheet(_ translation: CGFloat, _ detents: Set<PresentationDetent>, _ yVelocity: CGFloat) -> PresentationDetent? {
    let detents = Array(detents).sorted(by: { $0.size < $1.size })
    
    let position: [PresentationDetent] = detents.enumerated().compactMap { idx, detent in
        if idx < detents.index(before: detents.count) {
            let detentBracket = (
                lower: detents[idx],
                middle: detents[idx].size + ((detents[idx + 1].size - detents[idx].size) / 2),
                upper: detents[idx + 1]
            )
            
            if detentBracket.lower.size...detentBracket.upper.size ~= translation {
                if abs(yVelocity) > 1.8 {
                    return yVelocity > 0 ? detentBracket.upper : detentBracket.lower
                } else {
                    return translation > detentBracket.middle
                    ? detentBracket.upper
                    : detentBracket.lower
                }
            }
        }
        
        return nil
    }
    
    return position.first
}
