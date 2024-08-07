//
//  ConfigKey.swift
//  
//
//  Created by Wouter van de Kamp on 20/11/2022.
//

import SwiftUI

struct SheetPlusConfig: Equatable {
    let detents: Set<PresentationDetent>
    @Binding var selectedDetent: PresentationDetent
    let translation: CGFloat
    
    static func == (lhs: SheetPlusConfig, rhs: SheetPlusConfig) -> Bool {
        return lhs.selectedDetent == rhs.selectedDetent && lhs.translation == rhs.translation && lhs.detents == rhs.detents
    }
}

struct SheetPlusKey: PreferenceKey {
    static var defaultValue: SheetPlusConfig = SheetPlusConfig(detents: [], selectedDetent: .constant(.height(.zero)), translation: 0)

    static func reduce(value: inout SheetPlusConfig, nextValue: () -> SheetPlusConfig) {
        value = nextValue()
    }
}
