//
//  ExampleOverview.swift
//  BottomSheetExample
//
//  Created by Wouter van de Kamp on 24/05/2022.
//

import SwiftUI

struct ExampleOverview: View {
    var items = ["Stocks Examples"]
    var views = [StocksExampleView()]
    
    var body: some View {
        NavigationView {
            List(items.indices, id: \.self) { idx in
                NavigationLink(destination: views[idx]) {
                    Text(items[idx])
                }
            }
            .listStyle(.grouped)
            .navigationTitle("Examples")
        }
    }
}

struct ExampleOverview_Previews: PreviewProvider {
    static var previews: some View {
        ExampleOverview()
    }
}
