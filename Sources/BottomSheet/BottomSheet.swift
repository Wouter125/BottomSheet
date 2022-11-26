import SwiftUI

struct SheetPlus<HContent: View, MContent: View>: ViewModifier {
    @Binding private var isPresented: Bool
    
    let onDismiss: () -> Void
    let hcontent: HContent
    let mcontent: MContent
    
    @State private var offset = 0.0
    @State private var newValue = 0.0
    @State private var translation: CGFloat = 0
    @State private var startTime: DragGesture.Value?
    
    @State private var detents: Set<PresentationDetent> = []
    @State private var preferenceKey: SheetPlusConfigKey?
    @State private var limits: (min: CGFloat, max: CGFloat) = (min: 0, max: 0)
    
    @State private var translationKey: SheetPlusTranslationKey?
    
    var onDrag: ((_ position: CGFloat) -> Void)?
    
    public init(
        isPresented: Binding<Bool>,
        onDismiss: @escaping () -> Void,
        @ViewBuilder hcontent: () -> HContent,
        @ViewBuilder mcontent: () -> MContent
    ) {
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        self.hcontent = hcontent()
        self.mcontent = mcontent()
    }
    
    func body(content: Content) -> some View {
        ZStack() {
            content
            
            if isPresented {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        Spacer()
                        
                        VStack(spacing: 0) {
                            hcontent
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
                            
                                UIScrollViewWrapper(
                                    translation: $translation,
                                    preferenceKey: $preferenceKey,
                                    detents: $detents,
                                    limits: $limits
                                ) {
                                    VStack {
                                        mcontent
                                            .frame(width: geometry.size.width)
                                    }
                                }
                        }
                        .frame(height: limits.max)
                        .offset(y: limits.max - translation)
                        .onChange(of: translation) { newValue in
                            if limits.max == 0 { return }
                            translation = min(limits.max, max(newValue, limits.min))
                        }
                        .onAnimationChange(of: translation) { value in
                            translationKey?.$translation.wrappedValue = value
                        }
                        .animation(.easeInOut)
                        .onDisappear {
                            onDismiss()
                        }
                    }
                    .edgesIgnoringSafeArea(.bottom)
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
