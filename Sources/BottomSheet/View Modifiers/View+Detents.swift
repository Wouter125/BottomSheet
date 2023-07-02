//
//  File.swift
//  
//
//  Created by Wouter van de Kamp on 02/07/2023.
//

import SwiftUI

extension View {    
    public func presentationDetentsPlus(
        _ detents: Set<PresentationDetent>
    ) -> some View {
        let sortedDetents = Array(detents).sorted(by: { $0.size < $1.size })
        
        return self.preference(
            key: SheetPlusKey.self,
            value: SheetPlusConfig(
                detents: detents,
                selectedDetent: Binding(get: { sortedDetents.first! }, set: { _ in }),
                translation: sortedDetents.first!.size
            )
        )
    }
    
    public func presentationDetentsPlus(
        _ detents: Set<PresentationDetent>,
        selection: Binding<PresentationDetent>
    ) -> some View {
        return self.preference(
            key: SheetPlusKey.self,
            value: SheetPlusConfig(
                detents: detents,
                selectedDetent: selection,
                translation: selection.wrappedValue.size
            )
        )
    }
}

