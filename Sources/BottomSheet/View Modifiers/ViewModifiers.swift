//
//  File.swift
//  
//
//  Created by Wouter van de Kamp on 21/11/2022.
//

import SwiftUI

// MARK: - View extensions
extension View {
    public func sheetPlus<HContent: View, MContent: View>(
        isPresented: Binding<Bool>,
        onDismiss: @escaping () -> Void = {},
        header: () -> HContent,
        main: () -> MContent
    ) -> some View {
        modifier(
            SheetPlus(
                isPresented: isPresented,
                onDismiss: onDismiss,
                hcontent: header,
                mcontent: main
            )
        )
    }
    
    public func presentationDetentsPlus(
        _ detents: Set<PresentationDetent>
    ) -> some View {
        return self.preference(
            key: SheetPlusConfiguration.self,
            value: SheetPlusConfigKey(
                detents: detents
            )
        )
    }
    
    public func presentationDetentsPlus(
        _ detents: Set<PresentationDetent>,
        selection: Binding<PresentationDetent>
    ) -> some View {
        return self.preference(
            key: SheetPlusConfiguration.self,
            value: SheetPlusConfigKey(
                detents: detents,
                selection: selection
            )
        )
    }
    
    public func onSheetDrag(translation: Binding<CGFloat>) -> some View {
        return self.preference(
            key: SheetPlusTranslation.self,
            value: SheetPlusTranslationKey(
                translation: translation
            )
        )
    }
}
