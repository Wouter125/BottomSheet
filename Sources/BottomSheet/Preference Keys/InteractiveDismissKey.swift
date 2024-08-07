//
//  File.swift
//  
//
//  Created by Wouter van de Kamp on 25/12/2023.
//

import Foundation
import SwiftUI

struct SheetPlusInteractiveDismissDisabledKey: PreferenceKey {
    static var defaultValue: Bool = true

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}
