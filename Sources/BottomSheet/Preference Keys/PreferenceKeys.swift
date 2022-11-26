//
//  File.swift
//  
//
//  Created by Wouter van de Kamp on 20/11/2022.
//

import SwiftUI

struct SheetPlusPreferenceKey: Equatable {
    @Binding var selection: PresentationDetent
    let detents: Set<PresentationDetent>
    
    init(
        detents: Set<PresentationDetent>,
        selection: Binding<PresentationDetent> = .constant(.height(.zero))
    ) {
        self.detents = detents
        self._selection = selection
    }
    
    static func == (lhs: SheetPlusPreferenceKey, rhs: SheetPlusPreferenceKey) -> Bool {
        return lhs.selection == rhs.selection
    }
}

struct SheetPlusConfiguration: PreferenceKey {
    static var defaultValue: SheetPlusPreferenceKey = SheetPlusPreferenceKey(detents: [])
    
    static func reduce(value: inout SheetPlusPreferenceKey, nextValue: () -> SheetPlusPreferenceKey) {
        value = nextValue()
    }
}
