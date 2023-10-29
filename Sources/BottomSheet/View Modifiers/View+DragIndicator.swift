//
//  View+DragIndicator.swift
//  
//
//  Created by Wouter van de Kamp on 29/10/2023.
//

import SwiftUI

public enum VisibilityPlus {
    case hidden
    case visible
    case automatic
}

extension View {
    public func presentationDragIndicatorPlus(
        _ visibility: VisibilityPlus
    ) -> some View {
        return self.preference(
            key: SheetPlusIndicatorKey.self,
            value: visibility
        )
    }
}
