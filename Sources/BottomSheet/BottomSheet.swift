//
//  BottomSheet.swift
//
//
//  Created by Wouter van de Kamp on 26/11/2022.
//

import SwiftUI

struct SheetPlus<HContent: View, MContent: View, Background: View>: ViewModifier {
    @Binding private var isPresented: Bool
    
    @State private var translation: CGFloat = 0
    @State private var sheetConfig: SheetPlusConfig?
    @State private var showDragIndicator: VisibilityPlus?
    @State private var allowBackgroundInteraction: PresentationBackgroundInteractionPlus?
    @State private var isInteractiveDismissDisabled = true

    @State private var newValue = 0.0
    @State private var startTime: DragGesture.Value?
    
    @State private var detents: Set<PresentationDetent> = []
    @State private var limits: (min: CGFloat, max: CGFloat) = (min: 0, max: 0)

    @State private var initialSelectedDetent: PresentationDetent? = nil

    let mainContent: MContent
    let headerContent: HContent
    let animationCurve: SheetAnimation
    let onDismiss: () -> Void
    let onDrag: (CGFloat) -> Void
    let background: Background
    
    init(
        isPresented: Binding<Bool>,
        animationCurve: SheetAnimation,
        background: Background,
        onDismiss: @escaping () -> Void,
        onDrag: @escaping (CGFloat) -> Void,
        @ViewBuilder hcontent: () -> HContent,
        @ViewBuilder mcontent: () -> MContent
    ) {
        self._isPresented = isPresented
        
        self.animationCurve = animationCurve
        self.background = background
        self.onDismiss = onDismiss
        self.onDrag = onDrag
        
        self.headerContent = hcontent()
        self.mainContent = mcontent()
    }
    
    func body(content: Content) -> some View {
        ZStack() {
            content
                .allowsHitTesting(allowBackgroundInteraction == .disabled ? false : true)
                .onChange(of: isPresented) { newValue in
                    guard let initialSelectedDetent = initialSelectedDetent else { return }

                    if sheetConfig?.selectedDetent == PresentationDetent.height(0.0) && newValue == true {
                        sheetConfig?.selectedDetent = initialSelectedDetent
                    }
                }

            if isPresented {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        // If / else statement here breaks the animation from the bottom level
                        // Might want to see if we can refactor the top level animation a bit
                        DragIndicator(
                            translation: $translation,
                            detents: detents
                        )
                            .frame(height: showDragIndicator == .visible ? 22 : 0)
                            .opacity(showDragIndicator == .visible ? 1 : 0)

                        headerContent
                            .contentShape(Rectangle())
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
                                            sheetConfig?.selectedDetent = result
                                        }
                                    }
                            )

                        UIScrollViewWrapper(
                            translation: $translation,
                            preferenceKey: $sheetConfig,
                            isInteractiveDismissDisabled: $isInteractiveDismissDisabled,
                            limits: limits,
                            detents: detents
                        ) {
                            mainContent
                                .frame(width: geometry.size.width)
                        }
                    }
                    .background(background)
                    .frame(height:
                            (limits.max - geometry.safeAreaInsets.top) > 0
                                ? limits.max - geometry.safeAreaInsets.top
                                : limits.max
                    )
                    .onChange(of: translation) { newValue in
                        // Small little hack to make the iOS scroll behaviour work smoothly
                        if limits.max == 0 { return }

                        let minValue = isInteractiveDismissDisabled ? limits.min : 0
                        translation = min(limits.max, max(newValue, minValue))

                        currentGlobalTranslation = translation
                    }
                    .onAnimationChange(of: translation) { value in
                        onDrag(value)

                        if value <= 0 && sheetConfig?.selectedDetent == .height(.zero) {
                            isPresented = false
                        }
                    }
                    .offset(y: UIScreen.main.bounds.height - translation)
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
                .edgesIgnoringSafeArea([.bottom])
                .transition(.move(edge: .bottom))
            }
        }
        .onPreferenceChange(SheetPlusKey.self) { value in
            /// Quick hack to prevent the scrollview from resetting the height when keyboard shows up.
            /// Replace if the root cause has been located.
            if value.detents.count == 0 {
                isPresented = false
                return
            }

            if initialSelectedDetent == nil {
                initialSelectedDetent = value.selectedDetent
            }

            sheetConfig = value
            translation = value.translation

            detents = value.detents
            limits = detentLimits(detents: detents)
        }
        .onPreferenceChange(SheetPlusIndicatorKey.self) { value in
            showDragIndicator = value
        }
        .onPreferenceChange(SheetPlusBackgroundInteractionKey.self) { value in
            allowBackgroundInteraction = value
        }
        .onPreferenceChange(SheetPlusInteractiveDismissDisabledKey.self) { value in
            isInteractiveDismissDisabled = value
        }
    }
}
