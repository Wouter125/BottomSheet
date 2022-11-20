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
    @State private var test = 0
    
    @State private var preferenceKey: SheetPlusPreferenceKey?
    
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
                    let minimumLimit = detentLimits(detents: detents).min
                    let maximumLimit = detentLimits(detents: detents).max
                    
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
                                    detents: detents
                                ) {
                                    VStack {
                                        mcontent
                                            .frame(width: geometry.size.width)
                                    }
                                }
                        }
                        .frame(height: maximumLimit)
                        .offset(y: maximumLimit - translation)
                        .onChange(of: translation) { newValue in
                            if maximumLimit == 0 { return }
                            translation = min(maximumLimit, max(newValue, minimumLimit))
                        }
                        .onDisappear {
                            onDismiss()
                        }
                    }
                    .edgesIgnoringSafeArea(.bottom)
                }
            }
        }
        .onPreferenceChange(SheetPlusConfiguration.self) { value in
            detents = value.detents
            translation = value.$selection.wrappedValue.size
            
            self.preferenceKey = value
        }
    }
}
