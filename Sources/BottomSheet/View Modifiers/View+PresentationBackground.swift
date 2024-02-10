//
//  File.swift
//  
//
//  Created by Wouter van de Kamp on 27/01/2024.
//

import SwiftUI

extension View {
    public func presentationBackgroundPlus<V: View>(
        alignment: Alignment = .center,
        @ViewBuilder content: () -> V
    ) -> some View {
        return self.preference(
            key: SheetPlusPresentationBackgroundKey.self,
            value: EquatableBackground(alignment: alignment, view: AnyView(content()))
        )
    }
}
