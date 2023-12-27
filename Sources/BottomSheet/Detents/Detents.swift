//
//  Detents.swift
//  
//
//  Created by Wouter van de Kamp on 20/11/2022.
//

import SwiftUI

/**
 An enumeration to  represent various form of PresentationDetent
 
 - `small`: A small sized bottom sheet. `.fraction(0.2)`
 - `medium`: A medium sized bottom sheet, `.fraction(0.5)`
 - `large`: A large sized bottom sheet. `.fraction(0.9)`
 - `fraction`: Relative to screen height.
 - `height`: A constant height.
 */

public enum PresentationDetent: Hashable {
    /**
      .fraction(0.2)
     */
    case small
    
    /**
      .fraction(0.5)
     */
    case medium
    
    /**
      .fraction(0.9)
     */
    case large
    
    /**
      CGFloat 0 to 1
     */
    case fraction(CGFloat)
  
    /**
      A constant height.
     */
    case height(CGFloat)

    public var size: CGFloat {
        switch self {
        case .small:
            return PresentationDetentDefaults.small
        case .medium:
            return PresentationDetentDefaults.medium
        case .large:
            return PresentationDetentDefaults.large
        case .fraction(let fraction):
            return min(
                UIScreen.main.bounds.height * fraction,
                UIScreen.main.bounds.height
            )
        case .height(let height):
            return min(
                height,
                UIScreen.main.bounds.height
            )
        }
    }
}
