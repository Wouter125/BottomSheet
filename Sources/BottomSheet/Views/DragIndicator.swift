//
//  DragIndicator.swift
//  
//
//  Created by Wouter van de Kamp on 29/10/2023.
//

import SwiftUI

struct DragIndicator: View {
    @Binding var translation: CGFloat
    var detents: Set<PresentationDetent>

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .contentShape(Rectangle())
            .frame(width: 42, height: 6)
            .foregroundColor(Color(UIColor.systemGray3))
            .padding(.vertical, 8)
            .onTapGesture {
                let sortedDetents = detents.sorted { $0.size < $1.size }
                let nextDetent = sortedDetents.first(where: { $0.size > translation })

                if let nextDetent = nextDetent {
                    translation = nextDetent.size
                } else {
                    translation = sortedDetents.first?.size ?? 0
                }
            }
    }
}

struct DragIndicator_Previews: PreviewProvider {
    static var previews: some View {
        DragIndicator(
            translation: .constant(0),
            detents: []
        )
    }
}
