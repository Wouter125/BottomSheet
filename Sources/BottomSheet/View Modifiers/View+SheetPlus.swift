//
//  File.swift
//  
//
//  Created by Wouter van de Kamp on 21/11/2022.
//

import SwiftUI

// MARK: - View extensions
extension View {
    public func sheetPlus<HContent: View, MContent: View, Background: View>(
        isPresented: Binding<Bool>,
        animationCurve: SheetAnimation = SheetAnimation(
            mass: SheetAnimationDefaults.mass,
            stiffness: SheetAnimationDefaults.stiffness,
            damping: SheetAnimationDefaults.damping
        ),
        background: Background = Color(UIColor.systemBackground),
        onDismiss: @escaping () -> Void = {},
        header: () -> HContent,
        main: () -> MContent
    ) -> some View {
        modifier(
            SheetPlus(
                isPresented: isPresented,
                animationCurve: animationCurve,
                background: background,
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
    
    public func layoutBottomSheetList() -> some View {
        modifier(LayoutBottomSheetList())
    }
}

struct LayoutBottomSheetList: ViewModifier {
    @State var size: CGSize? = nil
    
    func body(content: Content) -> some View {
        if size == nil {
            return AnyView(
                content
                    .introspect { view in
                        size = view.contentSize
                    }
            )
        } else {
            return AnyView(
                VStack {
                    content
                        .frame(width: size!.width, height: size!.height)
                    Text("\(size!.height)")
                }
            )
        }
    }
}
