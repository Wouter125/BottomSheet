//
//  UIKitBottomSheetViewController.swift
//  
//
//  Created by Wouter van de Kamp on 10/03/2022.
//

import Foundation
import SwiftUI

protocol PanGestureDelegate: AnyObject {
    func didBeganPanning(_ translation: CGFloat)
    func didEndPanning(_ velocity: CGFloat)
}

class UIScrollViewController: UIViewController {
    var hostingController: UIHostingController<AnyView> = UIHostingController(rootView: AnyView(EmptyView()))
    var height: CGFloat

    weak var scrollViewDelegate: UIScrollViewDelegate?
    weak var panGestureDelegate: PanGestureDelegate?

    init(height: CGFloat) {
        self.height = height
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(hostingController.view)

        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        view.addConstraints([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
        
        updateScrollView()
    }
    
    func updateScrollView() {
        let scrollViews = view.findViews(subclassOf: UIScrollView.self)
        
        if !scrollViews.isEmpty {
            scrollViews[0].showsVerticalScrollIndicator = true
            scrollViews[0].delegate = scrollViewDelegate
        }
    }

    @objc private func didPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view).y
        let velocity = sender.velocity(in: view).y

        switch sender.state {
        case .changed:
            panGestureDelegate?.didBeganPanning(translation)
        case .ended:
            panGestureDelegate?.didEndPanning(velocity)
        default:
            break
        }

        sender.setTranslation(CGPoint.zero, in: view)
    }
}

// swiftlint:disable line_length
struct UIKitBottomSheetViewController<Header: View, Content: View, PositionEnum: RawRepresentable>: UIViewControllerRepresentable where PositionEnum.RawValue == CGFloat, PositionEnum: CaseIterable, PositionEnum: Equatable {
    @Binding var bottomSheetTranslation: CGFloat
    @Binding var initialVelocity: Double
    @Binding var bottomSheetPosition: PositionEnum
    
    var isDraggable: Bool
    var threshold: Double
    var excludedPositions: [PositionEnum]
    
    var header: () -> Header
    var content: () -> Content

    func makeUIViewController(context: Context) -> some UIScrollViewController {
        var height: CGFloat = 0
        
        if PositionModel.type == .relative {
            height = PositionEnum.allCases.sorted(by: { $0.rawValue < $1.rawValue }).last!.rawValue * UIScreen.main.bounds.height
        } else {
            height = PositionEnum.allCases.sorted(by: { $0.rawValue < $1.rawValue }).last!.rawValue
        }
        
        let viewController = UIScrollViewController(height: height)

        viewController.scrollViewDelegate = context.coordinator
        viewController.panGestureDelegate = context.coordinator

        viewController.hostingController.rootView = AnyView(VStack(spacing: 0) {
            header()
            content()
        })
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        context.coordinator.updateDraggable(isDraggable)
        context.coordinator.updateExcludedPositions(excludedPositions)
        
        uiViewController.scrollViewDelegate = context.coordinator
        uiViewController.panGestureDelegate = context.coordinator
        
        uiViewController.hostingController.rootView = AnyView(VStack(spacing: 0) {
            header()
            content()
        })
        
        uiViewController.view.setNeedsDisplay()
        
        // Wait for the UI to be layed out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            uiViewController.updateScrollView()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UIScrollViewDelegate, PanGestureDelegate {
        private var allPositions = PositionEnum.allCases.sorted(by: { $0.rawValue < $1.rawValue })

        private var isDraggable: Bool = true
        private var representable: UIKitBottomSheetViewController
        private var bottomSheetTranslation: CGFloat = 0
        private var scrollOffset: CGFloat = 0

        private var topPosition: CGFloat {
            let lastPosition = allPositions.last!.rawValue
            if PositionModel.type == .relative {
                return lastPosition * UIScreen.main.bounds.height
            }
            
            return lastPosition
        }

        private var bottomPosition: CGFloat {
            let firstPosition = allPositions.first!.rawValue
            if PositionModel.type == .relative {
                return firstPosition * UIScreen.main.bounds.height
            }
            
            return firstPosition
        }

        /// Computed var that returns the bottom sheet position the bottom sheet is currently in
        private var bottomSheetPosition: PositionEnum? {
            if PositionModel.type == .relative {
                for position in allPositions where (position.rawValue * UIScreen.main.bounds.height).rounded(.up) == representable.bottomSheetTranslation.rounded(.up)  {
                    return position
                }
            } else {
                for position in allPositions where position.rawValue.rounded(.up) == representable.bottomSheetTranslation.rounded(.up) {
                    return position
                }
            }

            return nil
        }

        init(_ representable: UIKitBottomSheetViewController) {
            self.representable = representable
        }
        
        internal func updateDraggable(_ isDraggable: Bool) {
            self.isDraggable = isDraggable
        }
        
        internal func updateExcludedPositions(_ positions: [PositionEnum]) {
            allPositions = allPositions.filter{ !positions.contains($0) }
        }

        private func shouldDragBottomSheet(basedOn scrollViewPosition: CGFloat, _ scrollView: UIScrollView) -> Bool {
            /// If the bottom sheet is in motion we should always proceed dragging before scrolling
            guard let bottomSheetPosition = bottomSheetPosition else { return true }
            
            /// We should drag the bottom sheet up if we are minimum and moving upwards
            if bottomSheetPosition == allPositions.first! {
                return scrollViewPosition > 0
            }

            /// We should drag the bottom sheet down if we are maximum and moving downwards
            if bottomSheetPosition == allPositions.last! {
                /// Set scrolloffset so the pan gesture can be corrected
                /// If we don't set this scrollOffset and you scroll down and start dragging afterwards it will jump
                /// Reason for this is that everything you already scrolled inside the scrollview will be added to the
                /// pan gesture
                if scrollViewPosition > scrollOffset {
                    scrollOffset = scrollViewPosition
                }

                return scrollViewPosition < 0
            }

            /// We should drag the bottom sheet up or down if we are in the middle
            return true
        }

        private func translateBottomSheet(by translation: CGFloat) {
            /// Disable panel movement if dragging is disabled
            if !isDraggable { return }
            
            representable.bottomSheetTranslation -= translation

            /// Limit the translation between it's max and min boundary
            representable.bottomSheetTranslation = max(
                bottomPosition,
                min(representable.bottomSheetTranslation, topPosition)
            )
        }

        private func snapBottomSheet(with yVelocity: CGFloat, scrollView: UIScrollView?) -> CGFloat? {
            if !isDraggable { return nil }
            
            let progress = (representable.bottomSheetTranslation - bottomPosition) / (topPosition - bottomPosition)
            
            /// Loop through all positions
            for (idx, position) in allPositions.enumerated() {
                guard idx + 1 < allPositions.count else { return nil }
                
                var startPosition: CGFloat = 0
                var endPosition: CGFloat = 0
                
                /// Grab the 2 positions next to each other
                if PositionModel.type == .relative {
                    startPosition = ((position.rawValue * UIScreen.main.bounds.height) - bottomPosition) / (topPosition - bottomPosition)
                    endPosition = ((allPositions[idx + 1].rawValue * UIScreen.main.bounds.height) - bottomPosition) / (topPosition - bottomPosition)
                } else {
                    startPosition = ((position.rawValue) - bottomPosition) / (topPosition - bottomPosition)
                    endPosition = ((allPositions[idx + 1].rawValue) - bottomPosition) / (topPosition - bottomPosition)
                }

                /// Check if current drag movement is within that range
                if startPosition...endPosition ~= progress {
                    /// Find the centerpoint between these two positions
                    let centerPosition = startPosition + ((endPosition - startPosition) / 2)
                    
                    // Normalize the threshold
                    let threshold = max(
                        0,
                        min(representable.threshold, 3)
                    )
                    
                    /// If velocity is strong enough we don't have to move over the center position,
                    /// we just snap to the correct position
                    if abs(yVelocity) > threshold && scrollView?.contentOffset == .zero {
                        if yVelocity > 0 {
                            let translation = (endPosition * (topPosition - bottomPosition)) + bottomPosition
                            representable.bottomSheetTranslation = translation
                        } else {
                            let translation = (startPosition * (topPosition - bottomPosition)) + bottomPosition
                            representable.bottomSheetTranslation = translation
                        }
                    } else {
                        /// Depending on whether the bottom sheet has been dragged over the center point,
                        /// snap it either to the bottom or top position
                        if progress > centerPosition {
                            let translation = (endPosition * (topPosition - bottomPosition)) + bottomPosition
                            representable.bottomSheetTranslation = translation
                        } else {
                            let translation = (startPosition * (topPosition - bottomPosition)) + bottomPosition
                            representable.bottomSheetTranslation = translation
                        }
                    }
                    
                    if let bottomSheetPosition = bottomSheetPosition {
                        representable.bottomSheetPosition = bottomSheetPosition
                    }
                    
                    return representable.bottomSheetTranslation
                }
            }
            
            return nil
        }

        // MARK: - ScrollView Delegate
        func scrollViewDidScroll(_ scrollView: UIScrollView) {            
            /// If the scrollview is smaller than the bottom sheet
            /// we don't need to scroll and only use the drag interation.
            if scrollView.contentSize.height > topPosition {
                /// Check if we should drag or scroll the bottom sheet
                guard scrollView.isTracking else { return }
                guard shouldDragBottomSheet(basedOn: scrollView.contentOffset.y, scrollView) else { return }
            }

            /// Track how far is being dragged on the bottom sheet
            let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview).y - scrollOffset
            let translationDelta = translation - bottomSheetTranslation
            translateBottomSheet(by: translationDelta)
            bottomSheetTranslation = translation
            
            /// Keep the view at the top when the bottom sheet is being dragged
            scrollView.contentOffset.y = .zero
        }

        func scrollViewWillEndDragging(
            _ scrollView: UIScrollView,
            withVelocity velocity: CGPoint,
            targetContentOffset: UnsafeMutablePointer<CGPoint>
        ) {
            let startPosition = representable.bottomSheetTranslation
            
            if let snapPosition = snapBottomSheet(with: velocity.y, scrollView: scrollView) {
                if startPosition.rounded(.up) != snapPosition.rounded(.up) {
                    targetContentOffset.pointee = .zero
                }
            }

            // Reset bottom sheet offset and translation so next time the delta starts at the same point
            scrollOffset = 0
            bottomSheetTranslation = 0
        }

        // MARK: - Pan Gesture Delegate
        func didBeganPanning(_ translation: CGFloat) {
            translateBottomSheet(by: translation)
        }

        func didEndPanning(_ velocity: CGFloat) {
            let _ = snapBottomSheet(with: (-velocity / 1000), scrollView: nil)
        }
    }
}
