//
//  SwiftUIView.swift
//  
//
//  Created by Wouter van de Kamp on 06/01/2024.
//

import SwiftUI

struct SheetPlusV2<HContent: View, MContent: View>: ViewModifier {
    @Binding private var isPresented: Bool

    @State private var translation: CGFloat = 0
    @State private var newValue = 0.0
    @State private var startTime: DragGesture.Value?

    @State private var sheetConfig: SheetPlusConfig?
    @State private var limits: (min: CGFloat, max: CGFloat) = (min: 0, max: 0)

    @State private var detents: Set<PresentationDetent> = []

    @State private var showDragIndicator: VisibilityPlus?
    @State private var cornerRadius: CGFloat?
    @State private var background: EquatableBackground?
    @State private var isInteractiveDismissDisabled = true

    @State private var viewWillPresent = false

    let animationCurve: SheetAnimation
    let onDrag: (CGFloat) -> Void
    let mainContent: MContent
    let headerContent: HContent
    let onDismiss: () -> Void

    init(
        isPresented: Binding<Bool>,
        animationCurve: SheetAnimation,
        onDismiss: @escaping () -> Void,
        onDrag: @escaping (CGFloat) -> Void = { _ in },
        @ViewBuilder hcontent: () -> HContent,
        @ViewBuilder mcontent: () -> MContent
    ) {
        self._isPresented = isPresented
        self.animationCurve = animationCurve

        self.onDismiss = onDismiss
        self.onDrag = onDrag

        self.headerContent = hcontent()
        self.mainContent = mcontent()
    }

    func body(content: Content) -> some View {
        ZStack {
            content
                .zIndex(1)
                .onChange(of: isPresented) { value in
                    if (value == true) {
                        viewWillPresent = value
                    } else {
                        translation = .zero
                    }
                }

            if viewWillPresent {
                // VStack to stick the sheet to the bottom
                VStack(spacing: 0) {
                    Spacer()

                    // VStack to keep the drag indicator and header at the top of the card
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            if showDragIndicator == .visible {
                                DragIndicator(
                                    translation: $translation,
                                    detents: detents
                                )
                            }

                            headerContent
                                .contentShape(Rectangle())
                        }
                        .gesture(
                            DragGesture(coordinateSpace: .global)
                                .onChanged { value in
                                    translation -= value.location.y - value.startLocation.y - newValue
                                    newValue = value.location.y - value.startLocation.y

                                    if startTime == nil {
                                        startTime = value
                                    }
                                }
                                .onEnded { value in
                                    onDragEnded(with: value)
                                }
                        )

                        Spacer()

                        UIScrollViewWrapper(
                            translation: $translation,
                            preferenceKey: $sheetConfig,
                            isInteractiveDismissDisabled: $isInteractiveDismissDisabled,
                            limits: limits,
                            detents: detents
                        ) {
                            mainContent
                        }

                        Spacer()
                    }
                    .frame(
                        width: UIScreen.main.bounds.width,
                        height: translation
                    )
                    .clipped()
                    .background(
                        ZStack(
                            alignment: background?.alignment ?? .center
                        ) {
                            background?.view
                        }
                            .cornerRadius(cornerRadius ?? 0)
                    )
                    .onChange(of: translation) { value in
                        let minLimit = isInteractiveDismissDisabled && isPresented ? limits.min : .zero
                        translation = min(limits.max, max(value, minLimit))
                    }
                    .onAnimationChange(of: translation) { value in
                        onDrag(value > .zero ? value : .zero)

                        print(translation)

                        if (translation == 0 && value == .zero) {
                            isPresented = false
                            viewWillPresent = false
                        }
                    }
                    .onDisappear {
                        onDismiss()
                    }
                    .animation(
                        .interpolatingSpring(
                            mass: animationCurve.mass,
                            stiffness: animationCurve.stiffness,
                            damping: animationCurve.damping
                        )
                    )
                }
                .edgesIgnoringSafeArea(.bottom)
                .zIndex(2)
            }
        }
        .onPreferenceChange(SheetPlusKey.self) { value in
            sheetConfig = value
            translation = value.translation

            detents = value.detents
            limits = detentLimits(detents: detents)
        }
        .onPreferenceChange(SheetPlusIndicatorKey.self) { value in
            showDragIndicator = value
        }
        .onPreferenceChange(SheetPlusInteractiveDismissDisabledKey.self) { value in
            isInteractiveDismissDisabled = value
        }
        .onPreferenceChange(SheetPlusPresentationCornerRadiusKey.self) { value in
            cornerRadius = value
        }
        .onPreferenceChange(SheetPlusPresentationBackgroundKey.self) { value in
            background = value
        }
    }

    func onDragEnded(with value: DragGesture.Value) {
        // Reset the distance on release so we start with a
        // clean translation next time
        newValue = 0

        // Calculate velocity based on pt/s so it matches the UIPanGesture
        let distance: CGFloat = value.translation.height
        let time: CGFloat = value.time.timeIntervalSince(startTime!.time)

        let yVelocity: CGFloat = -1 * ((distance / time) / 1000)
        startTime = nil

        if let result = snapBottomSheet(
            translation,
            detents,
            yVelocity,
            isInteractiveDismissDisabled
        ) {
            translation = result.size

            if result.size != .zero {
                sheetConfig?.selectedDetent = result
            }
        }
    }
}
