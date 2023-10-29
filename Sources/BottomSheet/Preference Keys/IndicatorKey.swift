//
//  IndicatorKey.swift
//  
//
//  Created by Wouter van de Kamp on 29/10/2023.
//

import Foundation
import SwiftUI

struct SheetPlusIndicatorKey: PreferenceKey {
    static var defaultValue: VisibilityPlus = .automatic

    static func reduce(value: inout VisibilityPlus, nextValue: () -> VisibilityPlus) {
        value = nextValue()
    }
}
