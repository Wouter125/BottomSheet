//
//  PresentationBackgroundKey.swift
//
//
//  Created by Wouter van de Kamp on 03/02/2024.
//

import SwiftUI

struct EquatableBackground: Equatable {
    let id = UUID().uuidString
    let alignment: Alignment
    let view: AnyView

    static func == (lhs: EquatableBackground, rhs: EquatableBackground) -> Bool {
        return lhs.id == rhs.id
    }
}

struct SheetPlusPresentationBackgroundKey: PreferenceKey {
    static var defaultValue: EquatableBackground = EquatableBackground(alignment: .center, view: AnyView(EmptyView()))

    static func reduce(
        value: inout EquatableBackground,
        nextValue: () -> EquatableBackground
    ) {
        value = nextValue()
    }
}
