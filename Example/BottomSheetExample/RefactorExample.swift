//
//  RefactorExample.swift
//  BottomSheetExample
//
//  Created by Wouter van de Kamp on 10/09/2022.
//

import SwiftUI
import BottomSheet

struct RefactorExample: View {
    @State var selectedDetent: BottomSheet.PresentationDetent = .large
    @State var isPresented: Bool = false
    @State var translation: CGFloat = BottomSheet.PresentationDetent.large.size
    
    var body: some View {
        VStack {
            Button("Test", action: {
                isPresented.toggle()
            })
            Text("\(selectedDetent.size)")
            Text("\(translation)")
            Spacer()
        }
            .sheetPlus(
                isPresented: $isPresented,
                header: {
                    HStack {
                        Text("Header")
                        Spacer()
                    }
                    .frame(height: 48)
                    .background(Color.orange)
                },
                main: {
                    VStack(spacing: 0) {
                        ForEach(0..<100, id: \.self) { obj in
                            HStack {
                                Spacer()
                                Text("\(obj)")
                                Spacer()
                            }
                        }
                    }
                    .presentationDetentsPlus(
                        [.fraction(0.3), .fraction(0.5), .fraction(1)],
                        selection: $selectedDetent
                    )
                    .onSheetDrag(translation: $translation)
                }
            )
    }
}

struct RefactorExample_Previews: PreviewProvider {
    static var previews: some View {
        RefactorExample()
    }
}
