//
//  ExampleOverview.swift
//  BottomSheetExample
//
//  Created by Wouter van de Kamp on 24/05/2022.
//

import SwiftUI

struct ExampleOverview: View {
    var items = ["Stocks Examples", "Maps Example", "Refactor Example"]
    var views: [AnyView] = [
        AnyView(StocksExampleView()),
        AnyView(MapsExampleView()),
        AnyView(RefactorExample())
    ]
    
    var body: some View {
        RefactorExample()
//        NavigationView {
//            List(items.indices, id: \.self) { idx in
//                NavigationLink(destination: views[idx]) {
//                    Text(items[idx])
//                }
//            }
//            .background(Color(UIColor.systemGroupedBackground))
//            .listStyle(.grouped)
//            .navigationTitle("Examples")
//        }
//        .navigationViewStyle(.stack)
    }
}

struct ExampleOverview_Previews: PreviewProvider {
    static var previews: some View {
        ExampleOverview()
    }
}
