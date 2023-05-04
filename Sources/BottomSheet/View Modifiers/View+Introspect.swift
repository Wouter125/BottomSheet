//
//  File.swift
//
//
//  Created by Wouter van de Kamp on 21/02/2023.
//

import SwiftUI

extension View {
    public func insertView<SomeView>(_ view: SomeView) -> some View where SomeView: View {
        overlay(view.frame(width: 1, height: 1))
    }
    
    public func introspect(
        customize: @escaping (UIScrollView) -> ()
    ) -> some View {
        insertView(UIKitIntrospectionView(customize: customize))
    }
}

public class IntrospectionUIView: UIView {
    required init() {
        super.init(frame: .zero)
        isHidden = true
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public struct UIKitIntrospectionView: UIViewRepresentable {
    let customize: (UIScrollView) -> Void
    
    public func makeUIView(context: UIViewRepresentableContext<UIKitIntrospectionView>) -> IntrospectionUIView {
        let view = IntrospectionUIView()
        
        // TODO: Figure out how to find the scrollView closest to the introspectionView
        DispatchQueue.main.async {
            var root = view.superview
            
            // Go to the top of the view hierachy to start our search for the right view
            while root?.superview != nil {
                root = root?.superview
            }
            
            // Traverse down in the view hierachy to find the "List"
            // List is using a collection or tableview, where both of them are subclasses of scrollviews
            // That's why we look for scrollviews
            if let scrollViews = root?.findViews(subclassOf: UICollectionView.self) {
                print(scrollViews)
                
                if scrollViews.count > 1 {
                    self.customize(scrollViews[1])
                }
            }
        }

        return view
    }
    
    public func updateUIView(_ uiView: IntrospectionUIView, context: Context) {
        
    }
}
