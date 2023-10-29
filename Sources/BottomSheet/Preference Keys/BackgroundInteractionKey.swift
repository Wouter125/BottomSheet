//
//  BackgroundInteractionKey.swift
//  
//
//  Created by Wouter van de Kamp on 29/10/2023.
//

import SwiftUI

// Currently using a global var.
// Might want to rework this by setting up the view modifiers a bit different.
// Probably something that we can hold translation in 1 var. Now both need to be in sync.
var currentGlobalTranslation: CGFloat = 0

public enum PresentationBackgroundInteractionPlus {
    case automatic
    case disabled
    case enabled

    public static func enabled(upThrough detent: PresentationDetent) -> PresentationBackgroundInteractionPlus {
        currentGlobalTranslation > detent.size ? .disabled : .enabled
    }
}

struct SheetPlusBackgroundInteractionKey: PreferenceKey {
    static var defaultValue: PresentationBackgroundInteractionPlus = .automatic

    static func reduce(value: inout PresentationBackgroundInteractionPlus, nextValue: () -> PresentationBackgroundInteractionPlus) {
        value = nextValue()
    }
}
