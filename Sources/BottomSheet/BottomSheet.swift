import SwiftUI

struct SheetPlus<HContent: View, MContent: View, Background: View>: ViewModifier {
    @Binding private var isPresented: Bool
    
    let onDismiss: () -> Void
    let hcontent: HContent
    let mcontent: MContent
    let animationCurve: SheetAnimation
    let background: Background
    
    @State private var offset = 0.0
    @State private var newValue = 0.0
    @State private var translation: CGFloat = 0
    @State private var startTime: DragGesture.Value?
    
    @State private var detents: Set<PresentationDetent> = []
    @State private var preferenceKey: SheetPlusConfigKey?
    @State private var limits: (min: CGFloat, max: CGFloat) = (min: 0, max: 0)
    
    @State private var translationKey: SheetPlusTranslationKey?
    
    @State private var listSize: CGSize?
    
    var onDrag: ((_ position: CGFloat) -> Void)?
    
    public init(
        isPresented: Binding<Bool>,
        animationCurve: SheetAnimation,
        background: Background,
        onDismiss: @escaping () -> Void,
        @ViewBuilder hcontent: () -> HContent,
        @ViewBuilder mcontent: () -> MContent
    ) {
        self._isPresented = isPresented
        
        self.animationCurve = animationCurve
        self.background = background
        self.onDismiss = onDismiss
        
        self.hcontent = hcontent()
        self.mcontent = mcontent()
    }
    
    func body(content: Content) -> some View {
        ZStack() {
            content
            
            // Additional renderer to calculate the view size of the list at top level
            if listSize == nil {
                mcontent
                    .opacity(0.01)
                    .disabled(true)
                    .introspect { view in
                        listSize = view.contentSize
                    }
            }
            
            if isPresented {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        Spacer()
                        
                        VStack(spacing: 0) {
                            hcontent
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
                                            
                                            if let result = snapBottomSheet(translation, detents, yVelocity) {
                                                translation = result.size
                                                preferenceKey?.$selection.wrappedValue = result
                                            }
                                        }
                                )
                            
                            if listSize != nil {
                                UIScrollViewWrapper(
                                    translation: $translation,
                                    preferenceKey: $preferenceKey,
                                    detents: $detents,
                                    limits: $limits,
                                    listSize: $listSize
                                ) {
                                    mcontent
                                        .frame(width: geometry.size.width)
                                }
                            }
                        }
                        .background(background)
                        .frame(height:
                                (limits.max - geometry.safeAreaInsets.top) > 0
                                    ? limits.max - geometry.safeAreaInsets.top
                                    : limits.max
                        )
                        .offset(y: limits.max - translation)
                        .onChange(of: translation) { newValue in
                            if limits.max == 0 { return }
                            translation = min(limits.max, max(newValue, limits.min))
                        }
                        .onAnimationChange(of: translation) { value in
                            translationKey?.$translation.wrappedValue = value
                        }
                        .animation(
                            .interpolatingSpring(
                                mass: animationCurve.mass,
                                stiffness: animationCurve.stiffness,
                                damping: animationCurve.damping
                            )
                        )
                        .onDisappear {
                            listSize = nil
                            onDismiss()
                        }
                    }
                    .edgesIgnoringSafeArea([.bottom])
                }
            }
        }
        .onPreferenceChange(SheetPlusTranslation.self) { value in
            self.translationKey = value
        }
        .onPreferenceChange(SheetPlusConfiguration.self) { value in
            detents = value.detents
            limits = detentLimits(detents: detents)
            translation = value.$selection.wrappedValue.size
            
            self.preferenceKey = value
        }
    }
}
