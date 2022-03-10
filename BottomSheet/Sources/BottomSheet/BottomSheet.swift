import SwiftUI

public struct AnimationConfiguration {
    var mass: Double
    var stiffness: Double
    var damping: Double
}

// swiftlint:disable line_length
public struct BottomSheetView<Header: View, Content: View, PositionEnum: RawRepresentable>: View where PositionEnum.RawValue == CGFloat, PositionEnum: CaseIterable, PositionEnum: Equatable {
    @State private var bottomSheetTranslation: CGFloat
    @State private var initialVelocity: Double = 0.0

    @Binding var position: PositionEnum

    let header: Header
    let content: Content
    let frameHeight: CGFloat

    private var animationConfiguration: AnimationConfiguration = AnimationConfiguration(
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
        self._bottomSheetTranslation = State(initialValue: position.wrappedValue.rawValue)
        self._position = position

        self.header = header()
        self.content = content()

        self.frameHeight = PositionEnum.allCases.sorted(by: { $0.rawValue < $1.rawValue }).last!.rawValue
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
                bottomSheetTranslation = newValue.rawValue
            }
            .onAnimationChange(of: bottomSheetTranslation) { newValue in
                onBottomSheetDrag?(newValue)
            }
            .frame(height: frameHeight)
            .offset(y: (geometry.size.height + geometry.safeAreaInsets.bottom) - bottomSheetTranslation)
            .animation(
                .interpolatingSpring(
                    mass: animationConfiguration.mass,
                    stiffness: animationConfiguration.stiffness,
                    damping: animationConfiguration.damping,
                    initialVelocity: initialVelocity * 10
                ),
                value: geometry.size.height - bottomSheetTranslation
            )
        }
    }
}

// MARK: - Properties
extension BottomSheetView {
    public func animationCurve(mass: Double = 1.2, stiffness: Double = 200, damping: Double = 25) -> BottomSheetView {
        var bottomSheetView = self
        bottomSheetView.animationConfiguration = AnimationConfiguration(
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

