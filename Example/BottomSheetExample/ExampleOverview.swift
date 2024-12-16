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
    case staticScrollView
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
        (label: "Stocks example", view: AnyView(StocksExample())),
        (label: "Static scrollview example", view: AnyView(StaticScrollViewExample()))
    ]

    @ViewBuilder
    var headerContent: some View {
        switch settings.activeSheetType {
        case .stocks:
            StocksHeader()
        case .staticScrollView:
            StaticScrollViewHeader()
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
                .presentationBackgroundInteractionPlus(.automatic)
                .presentationBackgroundPlus {
                    Color(UIColor.secondarySystemBackground)
                }
                .presentationCornerRadiusPlus(cornerRadius: 12)
        case .staticScrollView:
            StaticScrollViewContent()
                .presentationDetentsPlus(
                    [.height(380), .height(480), .large],
                    selection: $settings.selectedDetent
                )
                .presentationBackgroundInteractionPlus(.enabled(upThrough: .medium))
                .presentationBackgroundPlus {
                    Color(UIColor.red)
                }
                .presentationCornerRadiusPlus(cornerRadius: 12)
                .presentationDragIndicatorPlus(.visible)
                .interactiveDismissDisabledPlus(false)
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
                    settings.selectedDetent = .height(.zero)
                }
            }
            .navigationViewStyle(.stack)
        }
        .environmentObject(settings)
        .sheetPlus(
            isPresented: $settings.isPresented,
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
