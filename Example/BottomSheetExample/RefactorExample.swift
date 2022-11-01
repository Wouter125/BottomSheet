//
//  RefactorExample.swift
//  BottomSheetExample
//
//  Created by Wouter van de Kamp on 10/09/2022.
//

import SwiftUI

struct RefactorExample: View {
    @State var selectedDetent: PresentationDetent = .medium
    
    var body: some View {
        SheeetView(
            header: {
                HStack {
                    Text("Header")
                    Spacer()
                }
                .frame(height: 48)
                .background(Color.orange)
            },
            content: {
                VStack(spacing: 0) {
                    ForEach(0..<100, id: \.self) { obj in
                        HStack {
                            Spacer()
                            Text("\(obj)")
                            Spacer()
                        }
                    }
                }
            }
        )
        .presentationDetents(
            [.small, .medium, .large],
            selection: $selectedDetent
        )
    }
}

struct RefactorExample_Previews: PreviewProvider {
    static var previews: some View {
        RefactorExample()
    }
}
