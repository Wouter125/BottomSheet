//
//  File.swift
//  
//
//  Created by Wouter van de Kamp on 20/11/2022.
//

import SwiftUI

enum PresentationDetent: Hashable {
    case small
    case medium
    case large
    case fraction(CGFloat)
    case height(CGFloat)
    
    //TODO: implement solid hasher on values
    public func hash(into hasher: inout Hasher) {}
    
    public static func == (lhs: PresentationDetent, rhs: PresentationDetent) -> Bool {
        return lhs.size == rhs.size
    }
    
    var size: CGFloat {
        switch self {
        case .small:
            return PresentationDetentDefaults.small
        case .medium:
            return PresentationDetentDefaults.medium
        case .large:
            return PresentationDetentDefaults.large
        case .fraction(let fraction):
            return max(UIScreen.main.bounds.height * fraction, UIScreen.main.bounds.height)
        case .height(let height):
            return max(height, UIScreen.main.bounds.height * 0.9)
        }
    }
}
