//
//  File.swift
//  
//
//  Created by Wouter van de Kamp on 20/11/2022.
//

import Foundation
import SwiftUI
import UIKit

struct UIScrollViewWrapper<Content: View>: UIViewRepresentable {
    @Binding var translation: CGFloat
    @Binding var preferenceKey: SheetPlusConfigKey?
    @Binding var detents: Set<PresentationDetent>
    @Binding var limits: (min: CGFloat, max: CGFloat)
    
    private let scrollView = UIScrollView()
    private let hostingController = UIHostingController(rootView: AnyView(EmptyView()))
    
    let content: () -> Content
    
    func makeUIView(context: Context) -> some UIScrollView {
        hostingController.rootView = AnyView(self.content())
        
        scrollView.addSubview(hostingController.view)
        
        scrollView.contentInsetAdjustmentBehavior = .automatic
        scrollView.delegate = context.coordinator
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addConstraints([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
        
        hostingController.view.backgroundColor = .clear

        scrollView.layoutIfNeeded()
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        private var scrollOffset: CGFloat = 0
        private var newValue: CGFloat = 0
        
        private var representable: UIScrollViewWrapper
        
        init(_ representable: UIScrollViewWrapper) {
            self.representable = representable
        }
        
        private func shouldDragSheet(_ scrollViewPosition: CGFloat) -> Bool {
            if representable.translation >= representable.limits.max {
                if scrollViewPosition > scrollOffset {
                    scrollOffset = scrollViewPosition
                }

                return scrollViewPosition < 0
            }

            return true
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard scrollView.isTracking else { return }
            guard shouldDragSheet(scrollView.contentOffset.y) else { return }

            let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview).y - scrollOffset
            let translationDelta = translation - newValue

            representable.translation -= translationDelta

            newValue = translation

            scrollView.contentOffset.y = .zero
        }
        
        func scrollViewWillEndDragging(
            _ scrollView: UIScrollView,
            withVelocity velocity: CGPoint,
            targetContentOffset: UnsafeMutablePointer<CGPoint>
        ) {
            if representable.translation != representable.limits.max {
                targetContentOffset.pointee = .zero
            }
            
            if let result = snapBottomSheet(
                representable.translation,
                representable.detents,
                scrollView.contentOffset.y > 0 ? 0 : velocity.y
            ) {
                representable.translation = result.size
                representable.preferenceKey?.$selection.wrappedValue = result
            }
            
            scrollOffset = 0
            newValue = 0
        }
    }
}
