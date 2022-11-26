//
//  File.swift
//  
//
//  Created by Wouter van de Kamp on 26/11/2022.
//

import Foundation
import SwiftUI

struct SheetPlusTranslationKey: Equatable {
    @Binding var translation: CGFloat
    
    init(
        translation: Binding<CGFloat> = .constant(.zero)
    ) {
        self._translation = translation
    }
    
    static func == (lhs: SheetPlusTranslationKey, rhs: SheetPlusTranslationKey) -> Bool {
        return lhs.translation == rhs.translation
    }
}

struct SheetPlusTranslation: PreferenceKey {
    static var defaultValue: SheetPlusTranslationKey = SheetPlusTranslationKey()
    
    static func reduce(value: inout SheetPlusTranslationKey, nextValue: () -> SheetPlusTranslationKey) {
        value = nextValue()
    }
}
