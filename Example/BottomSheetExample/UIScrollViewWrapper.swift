//
//  UIKitWrapper.swift
//  BottomSheetExample
//
//  Created by Wouter van de Kamp on 17/09/2022.
//

import Foundation
import SwiftUI
import UIKit

struct UIScrollViewWrapper<Content: View>: UIViewRepresentable {
    @Binding var translation: CGFloat
    
    private let scrollView = UIScrollView()
    private let hostingController = UIHostingController(rootView: AnyView(EmptyView()))
    
    let detents: [PresentationDetent]
    let content: () -> Content
    
    func makeUIView(context: Context) -> some UIScrollView {
        hostingController.rootView = AnyView(self.content())
        
        scrollView.addSubview(hostingController.view)
        
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = context.coordinator
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addConstraints([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
        
        hostingController.view.backgroundColor = .orange

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
        
        private var minDetentLimit: CGFloat
        private var maxDetentLimit: CGFloat
        
        
        init(_ representable: UIScrollViewWrapper) {
            self.representable = representable
            
            let limits = detentLimits(detents: representable.detents)
            
            self.minDetentLimit = limits.min
            self.maxDetentLimit = limits.max
        }
        
        private func shouldDragSheet(_ scrollViewPosition: CGFloat) -> Bool {
            // If view is over the max detent, and scroll view position increases, start scrolling
            if representable.translation >= minDetentLimit {
                return scrollViewPosition <= 0
            }

            return true
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            // TODO: Delegates do not get triggered when contentSize smaller than the detent.
            // So this if check doesn't make any sense.
            if scrollView.contentSize.height > maxDetentLimit {
                guard scrollView.isTracking else { return }
                guard shouldDragSheet(scrollView.contentOffset.y) else { return }
            }

            let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview).y
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
            snapBottomSheet(representable.detents, velocity.y)
            
            newValue = 0
        }
        
        func snapBottomSheet(_ detents: [PresentationDetent], _ yVelocity: CGFloat) {
            detents.forEach { detent in
                print(detent.size, representable.translation)
            }
        }
    }
}
