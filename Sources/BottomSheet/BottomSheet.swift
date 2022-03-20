import SwiftUI

// swiftlint:disable line_length
public struct BottomSheetView<Header: View, Content: View, PositionEnum: RawRepresentable>: View where PositionEnum.RawValue == CGFloat, PositionEnum: CaseIterable, PositionEnum: Equatable {
    @State private var bottomSheetTranslation: CGFloat
    @State private var initialVelocity: Double = 0.0

    @Binding var position: PositionEnum

    let header: Header
    let content: Content
    let frameHeight: CGFloat

    private var AnimationModel: BottomSheet.AnimationModel = BottomSheet.AnimationModel(
        mass: 1.2,
        stiffness: 200,
        damping: 25
    )

    private var onBottomSheetDrag: ((_ position: CGFloat) -> Void)?

    public init(
        position: Binding<PositionEnum>,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        let lastPosition = PositionEnum.allCases.sorted(by: { $0.rawValue < $1.rawValue }).last!.rawValue
        
        if lastPosition <= 1 {
            PositionModel.type = .relative
            
            self._bottomSheetTranslation = State(initialValue: position.wrappedValue.rawValue * UIScreen.main.bounds.height)
            self.frameHeight = PositionEnum.allCases.sorted(by: { $0.rawValue < $1.rawValue }).last!.rawValue * UIScreen.main.bounds.height
        } else {
            PositionModel.type = .absolute
            
            self._bottomSheetTranslation = State(initialValue: position.wrappedValue.rawValue)
            self.frameHeight = PositionEnum.allCases.sorted(by: { $0.rawValue < $1.rawValue }).last!.rawValue
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
                header: {
                    header
                        .zIndex(1)
                },
                content: {
                    GeometryReader { _ in
                        content
                    }
                }
            )
            .onChange(of: $position.wrappedValue) { newValue in
                if PositionModel.type == .relative {
                    bottomSheetTranslation = newValue.rawValue * UIScreen.main.bounds.height
                } else {
                    bottomSheetTranslation = newValue.rawValue
                }
            }
            .onAnimationChange(of: bottomSheetTranslation) { newValue in
                onBottomSheetDrag?(newValue)
            }
            .frame(height: frameHeight)
            .offset(y: (geometry.size.height + geometry.safeAreaInsets.bottom) - bottomSheetTranslation)
            .animation(
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
}

// MARK: - Closures
extension BottomSheetView {
    public func onBottomSheetDrag(perform: @escaping (CGFloat) -> Void) -> BottomSheetView {
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

