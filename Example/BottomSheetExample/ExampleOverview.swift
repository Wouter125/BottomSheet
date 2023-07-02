//
//  ExampleOverview.swift
//  BottomSheetExample
//
//  Created by Wouter van de Kamp on 24/05/2022.
//

import SwiftUI
import BottomSheet

enum SheetExampleTypes {
    case home
    case stocks
}

class SheetSettings: ObservableObject {
    @Published var isPresented = false
    @Published var activeSheetType: SheetExampleTypes = .home
    @Published var selectedDetent: BottomSheet.PresentationDetent = .medium
    @Published var translation: CGFloat = BottomSheet.PresentationDetent.large.size
}

struct ExampleOverview: View {
    @StateObject var settings = SheetSettings()

    var views: [(label: String, view: AnyView)] = [
        (label: "Stocks example", view: AnyView(StocksExample()))
    ]

    @ViewBuilder
    var headerContent: some View {
        switch settings.activeSheetType {
        case .stocks:
            StocksHeader()
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    var mainContent: some View {
        switch settings.activeSheetType {
        case .stocks:
            StocksMainContent()
                .presentationDetentsPlus(
                    [.height(244), .medium, .large],
                    selection: $settings.selectedDetent
                )
        default:
            EmptyView()
        }
    }

    var body: some View {
        ZStack {
            NavigationView {
                List(views.indices, id: \.self) { index in
                    NavigationLink(destination: views[index].view) {
                        Text(views[index].label)
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
                .listStyle(.grouped)
                .navigationTitle("Examples")
                .onAppear {
                    settings.isPresented = false
                    settings.activeSheetType = .home
                    settings.selectedDetent = .medium
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
            onDrag: { translation in
                settings.translation = translation
            },
            header: { headerContent },
            main: {
                mainContent
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
            )
            .opacity(
                settings.activeSheetType == .stocks ? 1 : 0
            )
            ,
            alignment: .bottom
        )
    }
}

struct ExampleOverview_Previews: PreviewProvider {
    static var previews: some View {
        ExampleOverview()
    }
}
