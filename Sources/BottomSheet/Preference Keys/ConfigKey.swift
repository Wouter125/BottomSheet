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
        /// This prevents the translation changes to be called whenever the keyboard is triggered.
        /// If the keyboard gets triggered it will also reset the whole configkey and losing the binding.
        /// https://stackoverflow.com/questions/67644164/preferencekey-issue-swiftui-sometimes-seems-to-generate-additional-views-that
        value = nextValue() != defaultValue ? nextValue() : value
    }
}
