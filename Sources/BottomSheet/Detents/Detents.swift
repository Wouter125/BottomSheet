//
//  File.swift
//  
//
//  Created by Wouter van de Kamp on 20/11/2022.
//

import SwiftUI

public enum PresentationDetent: Hashable {
    case small
    case medium
    case large
    case fraction(CGFloat)
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
                (UIScreen.main.bounds.height - (ScreenSize.topInset ?? 0)) * fraction,
                UIScreen.main.bounds.height - (ScreenSize.topInset ?? 0)
            )
        case .height(let height):
            return min(
                height,
                UIScreen.main.bounds.height - (ScreenSize.topInset ?? 0)
            )
        }
    }
}
