//
//  StaticScrollViewExample.swift
//  BottomSheetExample
//
//  Created by Wouter van de Kamp on 28/10/2023.
//

import SwiftUI

struct StaticScrollViewExample: View {
    @EnvironmentObject var settings: SheetSettings

    var body: some View {
        VStack {
            Button("Close") {
                settings.isPresented.toggle()
            }

            Button("Change") {
                settings.selectedDetent = .large
            }

            Color.clear
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("\(settings.translation.rounded())")
                .onAppear {
                    settings.isPresented = true
                    settings.activeSheetType = .staticScrollView
                }
        }
    }
}

struct StaticScrollViewHeader: View {
    @State private var searchterm = ""

    var body: some View {
        VStack {
            TextField("Search item", text: $searchterm)
        }
    }
}

struct StaticScrollViewContent: View {
    var body: some View {
        ScrollView {
            ForEach(0..<5, id: \.self) { idx in
                Text("Item \(idx)")
            }
        }
    }
}

struct StaticScrollViewExample_Previews: PreviewProvider {
    static var previews: some View {
        StaticScrollViewExample()
    }
}
