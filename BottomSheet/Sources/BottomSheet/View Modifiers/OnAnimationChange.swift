//
//  OnAnimationChange.swift
//  
//
//  Created by Wouter van de Kamp on 10/03/2022.
//

import SwiftUI

struct AnimationObserverModifier<Value>: AnimatableModifier where Value: VectorArithmetic {
    var animatableData: Value {
        didSet {
            updateAnimationData()
        }
    }

    private var update: (CGFloat) -> Void

    init(observedValue: Value, update: @escaping (CGFloat) -> Void) {
        self.animatableData = observedValue
        self.update = update
    }

    func body(content: Content) -> some View {
        return content
    }

    private func updateAnimationData() {
        DispatchQueue.main.async {
            // swiftlint:disable force_cast
            update(animatableData as! CGFloat)
        }
   }
}

extension View {
    func onAnimationChange<Value: VectorArithmetic>(
        of value: Value,
        perform: @escaping (CGFloat) -> Void
    ) -> ModifiedContent<Self, AnimationObserverModifier<Value>> {
        return modifier(AnimationObserverModifier(observedValue: value, update: perform))
    }
}
