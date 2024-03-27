//
//  File.swift
//  
//
//  Created by Wouter van de Kamp on 25/12/2023.
//

import Foundation
import SwiftUI

extension View {
    public func interactiveDismissDisabledPlus(
        _ isDisabled: Bool
    ) -> some View {
        return self.preference(
            key: SheetPlusInteractiveDismissDisabledKey.self,
            value: isDisabled
        )
    }
}
