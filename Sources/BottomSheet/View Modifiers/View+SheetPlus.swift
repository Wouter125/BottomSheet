//
//  View+SheetPlus.swift
//  
//
//  Created by Wouter van de Kamp on 21/11/2022.
//

import SwiftUI

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
        onDrag: @escaping (CGFloat) -> Void = { _ in },
        header: () -> HContent = { EmptyView() },
        main: () -> MContent
    ) -> some View {
        modifier(
            SheetPlus(
                isPresented: isPresented,
                animationCurve: animationCurve,
                background: background,
                onDismiss: onDismiss,
                onDrag: onDrag,
                hcontent: header,
                mcontent: main
            )
        )
    }

    public func sheetPlusV2<HContent: View, MContent: View>(
        isPresented: Binding<Bool>,
        animationCurve: SheetAnimation = SheetAnimation(
            mass: SheetAnimationDefaults.mass,
            stiffness: SheetAnimationDefaults.stiffness,
            damping: SheetAnimationDefaults.damping
        ),
        onDismiss: @escaping () -> Void = {},
        onDrag: @escaping (CGFloat) -> Void = { _ in },
        header: () -> HContent = { EmptyView() },
        main: () -> MContent
    ) -> some View {
        modifier(
            SheetPlusV2(
                isPresented: isPresented,
                animationCurve: animationCurve,
                onDismiss: onDismiss,
                onDrag: onDrag,
                hcontent: header,
                mcontent: main
            )
        )
    }
}
