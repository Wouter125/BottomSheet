import SwiftUI

// swiftlint:disable line_length
public struct BottomSheetView<Header: View, Content: View, PositionEnum: RawRepresentable>: View where PositionEnum.RawValue == CGFloat, PositionEnum: CaseIterable, PositionEnum: Equatable {
    @State private var bottomSheetTranslation: CGFloat
    @State private var initialVelocity: Double = 0.0
    @State private var shouldAnimate: Bool = false
    
    @GestureState private var translation: CGFloat = 0
    
    @Binding var position: PositionEnum

    let header: Header
    let content: Content
    let frameHeight: CGFloat
    
    private var AnimationModel: BottomSheet.AnimationModel = BottomSheet.AnimationModel(
        mass: BottomSheetDefaults.Animation.mass,
        stiffness: BottomSheetDefaults.Animation.stiffness,
        damping: BottomSheetDefaults.Animation.damping
    )
    
    private var threshold = BottomSheetDefaults.Interaction.threshold
    private var excludedPositions: [PositionEnum] = []
    private var isDraggable = true
    private var background: AnyView = AnyView(EmptyView())
    private var alignment: Alignment = .center

    private var onBottomSheetDrag: ((_ position: CGFloat, _ modulatedPosition: CGFloat) -> Void)?
    
    private var firstPosition: CGFloat
    private var lastPosition: CGFloat

    public init(
        position: Binding<PositionEnum>,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        let positions = PositionEnum.allCases.sorted(by: { $0.rawValue < $1.rawValue })
        
        firstPosition = positions.first!.rawValue
        lastPosition = positions.last!.rawValue
        
        if lastPosition <= 1 {
            PositionModel.type = .relative
            
            self._bottomSheetTranslation = State(initialValue: position.wrappedValue.rawValue * UIScreen.main.bounds.height)
            self.frameHeight = lastPosition * UIScreen.main.bounds.height
        } else {
            PositionModel.type = .absolute
            
            self._bottomSheetTranslation = State(initialValue: position.wrappedValue.rawValue)
            self.frameHeight = lastPosition
        }
        
        self._position = position

        self.header = header()
        self.content = content()
    }

    public var body: some View {
        GeometryReader { geometry in
            UIKitBottomSheetViewController(
                bottomSheetTranslation: $bottomSheetTranslation,
                initialVelocity: $initialVelocity,
                bottomSheetPosition: $position,
                isDraggable: isDraggable,
                threshold: threshold,
                excludedPositions: excludedPositions,
                background: background,
                alignment: alignment,
                header: {
                    VStack {
                        header
                            .zIndex(1)
                    }
                    .gesture (
                        DragGesture().updating($translation) { currentState, gestureState, _ in
                            let delta = gestureState - currentState.translation.height
                            print(delta)
                            gestureState = currentState.translation.height
                        }
                    )
                },
                content: {
                    GeometryReader { _ in
                        content
                    }
                }
            )
            .onAppear {
                DispatchQueue.main.async {
                    shouldAnimate = true
                }
            }
            .onChange(of: $position.wrappedValue) { newValue in
                position = newValue
                
                if PositionModel.type == .relative {
                    bottomSheetTranslation = newValue.rawValue * UIScreen.main.bounds.height
                } else {
                    bottomSheetTranslation = newValue.rawValue
                }
            }
            .onAnimationChange(of: bottomSheetTranslation) { newValue in
                let modulatedValue = newValue.modulate(
                    from: [
                        firstPosition * geometry.size.height,
                        lastPosition * geometry.size.height
                    ],
                    to: [
                        0,
                        1
                    ],
                    limit: true
                )
                
                onBottomSheetDrag?(newValue, modulatedValue)
            }
            .frame(height: frameHeight)
            .offset(y: (geometry.size.height + geometry.safeAreaInsets.bottom) + translation)
            .animation(
                !shouldAnimate ?
                    .none :
                    .interpolatingSpring(
                        mass: AnimationModel.mass,
                        stiffness: AnimationModel.stiffness,
                        damping: AnimationModel.damping,
                        initialVelocity: initialVelocity * 10
                    ),
                    value: geometry.size.height - (bottomSheetTranslation * geometry.size.height)
            )
        }
    }
}

// MARK: - Properties
extension BottomSheetView {
    public func animationCurve(mass: Double = 1.2, stiffness: Double = 200, damping: Double = 25) -> BottomSheetView {
        var bottomSheetView = self
        bottomSheetView.AnimationModel = BottomSheet.AnimationModel(
            mass: mass,
            stiffness: stiffness,
            damping: damping
        )
        return bottomSheetView
    }
    
    public func background<Background: View>(
        _ background: Background,
        alignment: Alignment = .center
    ) -> BottomSheetView {
        var bottomSheetView = self
        bottomSheetView.background = AnyView(background)
        return bottomSheetView
    }
    
    public func snapThreshold(_ threshold: Double = 0) -> BottomSheetView {
        var bottomSheetView = self
        bottomSheetView.threshold = threshold
        return bottomSheetView
    }
    
    public func isDraggable(_ isDraggable: Bool) -> BottomSheetView {
        var bottomSheetView = self
        bottomSheetView.isDraggable = isDraggable
        return bottomSheetView
    }
    
    public func excludeSnapPositions(_ positions: [PositionEnum]) -> BottomSheetView {
        var bottomSheetView = self
        bottomSheetView.excludedPositions = positions
        return bottomSheetView
    }
}

// MARK: - Closures
extension BottomSheetView {
    public func onBottomSheetDrag(perform: @escaping (CGFloat, CGFloat?) -> Void) -> BottomSheetView {
        var bottomSheetView = self
        bottomSheetView.onBottomSheetDrag = perform
        return bottomSheetView
    }
}

// MARK: - Convenience initializers
extension BottomSheetView where Header == EmptyView {
    init(
        position: Binding<PositionEnum>,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            position: position,
            header: { EmptyView() },
            content: content
        )
    }
}

