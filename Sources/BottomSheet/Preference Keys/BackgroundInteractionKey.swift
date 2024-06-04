//
//  BackgroundInteractionKey.swift
//  
//
//  Created by Wouter van de Kamp on 29/10/2023.
//

import SwiftUI

public struct PresentationBackgroundInteractionPlus: Hashable, Sendable {
    internal enum Kind: Hashable, Sendable {
        case automatic
        case disabled
        case enabled(upThrough: PresentationDetent?)
    }

    internal let kind: Kind

    internal init(kind: Kind) {
        self.kind = kind
    }

    public static let automatic = Self.init(kind: .automatic)
    public static let enabled = Self.init(kind: .enabled(upThrough: nil))
    public static let disabled = Self.init(kind: .disabled)

    public static func enabled(upThrough detent: PresentationDetent) -> Self {
        .init(kind: .enabled(upThrough: detent))
    }
}

struct SheetPlusBackgroundInteractionKey: PreferenceKey {
    static var defaultValue: CGFloat? = nil

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = nextValue()
    }
}
