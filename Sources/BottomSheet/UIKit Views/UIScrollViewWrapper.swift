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
    @Binding var listSize: CGSize?
    
    private let scrollView = UIScrollView()
    private let hostingController = UIHostingController(rootView: AnyView(EmptyView()))
    
    let content: () -> Content
    
    func makeUIView(context: Context) -> UIScrollView {
        hostingController.rootView = AnyView(self.content())
        
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
        // Hack to implement a custom scrollsize, so lists gets rendered.
        // Apart from that we disable the list height
        if let listSize = listSize {
            print(scrollView.subviews[0].subviews)
            scrollView.contentSize = CGSize(width: listSize.width, height: listSize.height)
            
            scrollView.layoutSubviews()
        }
//            scrollView.subviews[0].frame = CGRect(x: 0, y: 0, width: 375, height: 1595)
//            
//            let test = scrollView.subviews[0].subviews
//            
//            test[test.count - 2].frame = CGRect(x: 0, y: 210, width: listSize.width, height: listSize.height)
//            
//            scrollView.subviews[0].layoutSubviews()
//            scrollView.subviews[0].layoutIfNeeded()
//            
//            print(scrollView.subviews[0])
//            
//            print(scrollView.subviews[0].frame)
//        }
//
//
//
//
//            let listViews = scrollView.findViews(subclassOf: UICollectionView.self)
//
//            print(listViews)
//
//            if listViews.count > 0 {
//                listViews[0].contentSize = CGSize(width: listSize.width, height: listSize.height)
//                listViews[0].frame = CGRect(x: 0, y: 0, width: listSize.width, height: listSize.height)
//                listViews[0].isScrollEnabled = false
//            }
//
//            scrollView.contentSize = CGSize(width: listSize.width, height: listSize.height + scrollView.subviews[0].frame.height)
//        }
        
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
            guard shouldDragSheet(scrollView.contentOffset.y) else {
                scrollView.showsVerticalScrollIndicator = true
                return
            }

            let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview).y - scrollOffset
            let translationDelta = translation - newValue

            representable.translation -= translationDelta

            newValue = translation
            
            scrollView.showsVerticalScrollIndicator = false
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
