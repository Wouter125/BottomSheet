//
//  UIScrollViewWrapper.swift
//  
//
//  Created by Wouter van de Kamp on 20/11/2022.
//

import Foundation
import SwiftUI
import UIKit

internal struct UIScrollViewWrapper<Content: View>: UIViewRepresentable {
    @Binding var translation: CGFloat
    @Binding var preferenceKey: SheetPlusConfig?
    @Binding var isInteractiveDismissDisabled: Bool

    let limits: (min: CGFloat, max: CGFloat)
    let detents: Set<PresentationDetent>

    let content: () -> Content
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        let hostingController = context.coordinator.hostingController
        
        scrollView.addSubview(hostingController.view)
        
        scrollView.contentInsetAdjustmentBehavior = .automatic
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = context.coordinator
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addConstraints([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
        
        hostingController.view.backgroundColor = .clear
        scrollView.backgroundColor = .clear

        scrollView.layoutIfNeeded()
        
        return scrollView
    }
    
    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.limits = limits
        context.coordinator.detents = detents

        context.coordinator.hostingController.rootView = self.content()
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(
            representable: self,
            hostingController: UIHostingController(rootView: content()),
            limits: limits,
            detents: detents
        )
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        private var scrollOffset: CGFloat = 0
        private var newValue: CGFloat = 0
        
        var representable: UIScrollViewWrapper
        var hostingController: UIHostingController<Content>
        
        var limits: (min: CGFloat, max: CGFloat)
        var detents: Set<PresentationDetent>
        
        init(
            representable: UIScrollViewWrapper,
            hostingController: UIHostingController<Content>,
            limits: (min: CGFloat, max: CGFloat),
            detents: Set<PresentationDetent>
        ) {
            self.hostingController = hostingController
            self.limits = limits
            self.detents = detents
            self.representable = representable
        }
        
        private func shouldDragSheet(_ scrollViewPosition: CGFloat, isFixedHeight: Bool) -> Bool {
            // Translation on a scrollview without an overflow get's set to 0 somehow.
            // Implemented this check to prevent it from snapping back to the original position.
            // Need to dive deeper to figure out why it gets set to 0.
            if isFixedHeight && representable.translation == 0 {
                if scrollViewPosition > scrollOffset {
                    scrollOffset = scrollViewPosition
                }

                return scrollViewPosition < 0
            }

            if representable.translation >= limits.max {
                if scrollViewPosition > scrollOffset {
                    scrollOffset = scrollViewPosition
                }

                return scrollViewPosition < 0
            }

            return true
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let isFixedHeight = scrollView.contentSize.height < scrollView.frame.size.height

            guard scrollView.isTracking else { return }
            guard shouldDragSheet(scrollView.contentOffset.y, isFixedHeight: isFixedHeight) else {
                scrollView.showsVerticalScrollIndicator = true
                return
            }
            
            let localTranslation = scrollView.panGestureRecognizer.translation(in: scrollView.superview).y - scrollOffset
            let translationDelta = localTranslation - newValue

            representable.translation -= translationDelta

            newValue = localTranslation

            scrollView.showsVerticalScrollIndicator = false
            scrollView.contentOffset.y = .zero
        }

        func scrollViewWillEndDragging(
            _ scrollView: UIScrollView,
            withVelocity velocity: CGPoint,
            targetContentOffset: UnsafeMutablePointer<CGPoint>
        ) {
            if representable.translation != limits.max {
                targetContentOffset.pointee = .zero
            }
            
            if let result = snapBottomSheet(
                representable.translation,
                detents,
                scrollView.contentOffset.y > 0 ? 0 : velocity.y,
                representable.isInteractiveDismissDisabled
            ) {
                representable.translation = result.size

                if result.size != .zero {
                    representable.preferenceKey?.selectedDetent = result
                }
            }

            scrollOffset = 0
            newValue = 0
        }
    }
}
