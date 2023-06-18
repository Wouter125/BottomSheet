//
//  File.swift
//  
//
//  Created by Wouter van de Kamp on 20/11/2022.
//

import SwiftUI

struct SheetPlusConfigKey: Equatable {
    let id = UUID().uuidString
    
    let detents: Set<PresentationDetent>
    @Binding var selection: PresentationDetent
    
    init(
        detents: Set<PresentationDetent>,
        selection: Binding<PresentationDetent> = .constant(.height(.zero))
    ) {
        self.detents = detents
        self._selection = selection
    }
    
    static func == (lhs: SheetPlusConfigKey, rhs: SheetPlusConfigKey) -> Bool {
        return lhs.id == rhs.id
    }
}

struct SheetPlusConfiguration: PreferenceKey {
    static var defaultValue: SheetPlusConfigKey = SheetPlusConfigKey(detents: [])
    
    static func reduce(value: inout SheetPlusConfigKey, nextValue: () -> SheetPlusConfigKey) {
        value = nextValue()
    }
}
