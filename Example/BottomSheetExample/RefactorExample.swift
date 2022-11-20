//
//  RefactorExample.swift
//  BottomSheetExample
//
//  Created by Wouter van de Kamp on 10/09/2022.
//

import SwiftUI
import BottomSheet

struct RefactorExample: View {
    @State var selectedDetent: PresentationDetent = .large
    @State var isPresented: Bool = false
    
    var body: some View {
        VStack {
            Button("Test", action: {
                isPresented.toggle()
            })
            Text("\(selectedDetent.size)")
            Spacer()
        }
            .sheetPlus(
                isPresented: $isPresented,
                onDismiss: {
                  print("hallo")
                },
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
                        [.medium, .large],
                        selection: $selectedDetent
                    )
                }
            )
    }
}

struct RefactorExample_Previews: PreviewProvider {
    static var previews: some View {
        RefactorExample()
    }
}
