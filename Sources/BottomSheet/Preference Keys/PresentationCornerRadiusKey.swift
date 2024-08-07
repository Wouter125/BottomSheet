//
//  File.swift
//  
//
//  Created by Wouter van de Kamp on 30/01/2024.
//

import SwiftUI

struct SheetPlusPresentationCornerRadiusKey: PreferenceKey {
    static var defaultValue: CGFloat? = nil

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = nextValue()
    }
}
