//
//  SheeetView.swift
//  BottomSheetExample
//
//  Created by Wouter van de Kamp on 10/09/2022.
//

import SwiftUI

struct PresentationDetentDefaults {
    static let small: CGFloat = (UIScreen.main.bounds.height / 10) * 2
    static let medium: CGFloat = (UIScreen.main.bounds.height / 10) * 5
    static let large: CGFloat = (UIScreen.main.bounds.height / 10) * 8
}

enum PresentationDetent {
    case small
    case medium
    case large
    case fraction(CGFloat)
    case height(CGFloat)
    
    var size: CGFloat {
        switch self {
        case .small:
            return PresentationDetentDefaults.small
        case .medium:
            return PresentationDetentDefaults.medium
        case .large:
            return PresentationDetentDefaults.large
        case .fraction(let fraction):
            return max(UIScreen.main.bounds.height * fraction, UIScreen.main.bounds.height * 0.9)
        case .height(let height):
            return max(height, UIScreen.main.bounds.height * 0.9)
        }
    }
}

func detentLimits(detents: [PresentationDetent]) -> (min: CGFloat, max: CGFloat) {
    let normalizedDetents: [CGFloat] = detents
        .map { detent in
            switch detent {
            case .small:
                return UIScreen.main.bounds.height - PresentationDetentDefaults.small
            case .medium:
                return UIScreen.main.bounds.height - PresentationDetentDefaults.medium
            case .large:
                return UIScreen.main.bounds.height - PresentationDetentDefaults.large
            case .fraction(let fraction):
                return UIScreen.main.bounds.height - ((UIScreen.main.bounds.height / 100) * fraction)
            case .height(let height):
                return UIScreen.main.bounds.height - height
            }
        }
        .sorted(by: >)

    
    return (min: normalizedDetents.first ?? 0, max: normalizedDetents.last ?? 0)
}

struct SheeetView<Header: View, Content: View>: View {
    let header: Header
    let content: Content
    
    @State private var offset = 0.0
    @State private var newValue = 0.0
    @State private var translation: CGFloat = 0.0
    
    @State private var selection: PresentationDetent = .small
    
    private var detents: [PresentationDetent] = []
    
    public init(
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header()
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            let viewHeight = geometry.size.height + geometry.safeAreaInsets.bottom
            let maxOffset = detentLimits(detents: detents).max
            let minOffset = detentLimits(detents: detents).min

            VStack(alignment: .center, spacing: 0) {
                header
                    .gesture(
                        DragGesture(coordinateSpace: .global)
                            .onChanged { value in
                                translation -= value.location.y - value.startLocation.y - newValue
                                newValue = value.location.y - value.startLocation.y
                            }
                            .onEnded { value in
                                // Reset the distance on release so we start with a
                                // clean translation next time
                                newValue = 0
                            }
                    )

                UIScrollViewWrapper(
                    translation: $translation,
                    detents: detents
                ) {
                    content
                        .frame(width: geometry.size.width)
                }

            }
            .onChange(of: translation) { newValue in
                print(maxOffset, minOffset)
                translation = max(maxOffset, min(newValue, minOffset))
            }
            .frame(
                width: geometry.size.width,
                height: detentLimits(detents: detents).min
            )
            .background(Color.red)
            .ignoresSafeArea(.all, edges: [.bottom])
            .offset(y: max(maxOffset, min(viewHeight - translation, minOffset)))
        }
    }
}

// MARK: - Properties
extension SheeetView {
    func presentationDetents(
        _ detents: [PresentationDetent],
        selection: Binding<PresentationDetent>? = nil
    ) -> SheeetView {
        var sheeetView = self
        
        sheeetView.detents = detents

        if let selection = selection {
            sheeetView._translation = State(initialValue: selection.wrappedValue.size)
        } else {
            sheeetView._translation = State(initialValue: detentLimits(detents: detents).min)
        }
        
        return sheeetView
    }
}
