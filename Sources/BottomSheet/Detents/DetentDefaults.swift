//
//  File.swift
//  
//
//  Created by Wouter van de Kamp on 20/11/2022.
//

import SwiftUI

struct ScreenSize {
    static let topInset = UIApplication.shared.windows.first!.safeAreaInsets.top
}

struct PresentationDetentDefaults {
    static let small: CGFloat = ((UIScreen.main.bounds.height - ScreenSize.topInset) / 10) * 2
    static let medium: CGFloat = ((UIScreen.main.bounds.height - ScreenSize.topInset) / 10) * 5
    static let large: CGFloat = (UIScreen.main.bounds.height - ScreenSize.topInset)
}
