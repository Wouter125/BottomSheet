//
//  ExampleOverview.swift
//  BottomSheetExample
//
//  Created by Wouter van de Kamp on 24/05/2022.
//

import SwiftUI
import BottomSheet

class SheetSettings: ObservableObject {
    @Published var isPresented = false
    @Published var selectedDetent: BottomSheet.PresentationDetent = .medium
    @Published var translation: CGFloat = BottomSheet.PresentationDetent.large.size
}

struct ExampleOverview: View {
    @StateObject var settings = SheetSettings()

    var items = ["Stocks Examples"]
    var views: [AnyView] = [
        AnyView(StocksExample())
//        AnyView(MapsExampleView()),
    ]

    var body: some View {
        ZStack {
            NavigationView {
                List(items.indices, id: \.self) { idx in
                    NavigationLink(destination: views[idx]) {
                        Text(items[idx])
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
                .listStyle(.grouped)
                .navigationTitle("Examples")
                .onAppear {
                    settings.isPresented = false
                }
            }
            .navigationViewStyle(.stack)
        }
        .environmentObject(settings)
        .sheetPlus(
            isPresented: $settings.isPresented,
            background: (
                Color(UIColor.secondarySystemBackground)
                    .cornerRadius(12, corners: [.topLeft, .topRight])
            ),
            header: { StocksExample().sheetHeaderContent },
            main: {
                StocksExample().sheetMainContent
                    .presentationDetentsPlus(
                        [.height(244), .medium, .large],
                        selection: $settings.selectedDetent
                    )
                    .onSheetDrag(translation: $settings.translation)
            }
        )
        .overlay(
            VStack(spacing: 0) {
                Divider()
                 .frame(height: 1)
                 .background(Color(UIColor.systemGray6))

                HStack {
                    Text("Yahoo Finance")
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(
                Color(UIColor.secondarySystemBackground)
                    .edgesIgnoringSafeArea([.bottom])
            ),
            alignment: .bottom
        )
    }
}

struct ExampleOverview_Previews: PreviewProvider {
    static var previews: some View {
        ExampleOverview()
    }
}
