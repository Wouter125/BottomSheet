//
//  BackgroundInteractionKey.swift
//  
//
//  Created by Wouter van de Kamp on 29/10/2023.
//

import SwiftUI

public enum PresentationBackgroundInteractionPlus: Equatable {
    case automatic
    case disabled
    case enabled

    internal static var detent: PresentationDetent?
    internal static var enabledUpThrough: PresentationBackgroundInteractionPlus = .enabledUpThrough

    public static func enabled(upThrough detent: PresentationDetent) -> PresentationBackgroundInteractionPlus {
        self.detent = detent
        return enabledUpThrough
    }
}

struct SheetPlusBackgroundInteractionKey: PreferenceKey {
    static var defaultValue: PresentationBackgroundInteractionPlus = .automatic

    static func reduce(value: inout PresentationBackgroundInteractionPlus, nextValue: () -> PresentationBackgroundInteractionPlus) {
        value = nextValue()
    }
}
