//
//  SheetV2Example.swift
//  BottomSheetExample
//
//  Created by Wouter van de Kamp on 06/01/2024.
//

import SwiftUI
import BottomSheet

class SheetSettingsV2: ObservableObject {
    @Published var isPresented = false
    @Published var selectedDetent: BottomSheet.PresentationDetent = .medium
}

struct NavigationViewV2: View {
    @State var text = "Text"
    @StateObject var settings = SheetSettings()

    var views: [(label: String, view: AnyView)] = [
        (label: "V2 example", view: AnyView(SheetV2Example()))
    ]

    var body: some View {
        NavigationView {
            List(views.indices, id: \.self) { index in
                NavigationLink(destination: views[index].view) {
                    Text(views[index].label)
                }
            }
            .onAppear {
                settings.isPresented = false
            }
        }
        .environmentObject(settings)
        .sheetPlusV2(
            isPresented: $settings.isPresented,
            header: {
                Text("Test")
            },
            main: {
                VStack {
                    Spacer()
                    Text("Main content")
                    Spacer()
                }
                .presentationDetentsPlus(
                    [
                        PresentationDetent.fraction(0.1),
                        PresentationDetent.fraction(0.3),
                        PresentationDetent.fraction(0.8)
                    ],
                    selection: $settings.selectedDetent
                )
                .presentationBackgroundPlus {
                    Color.yellow
                }
//                .presentationBackgroundInteractionPlus(.enabled(upThrough: .fraction(0.2)))
                .presentationDragIndicatorPlus(.visible)
                .presentationCornerRadiusPlus(cornerRadius: 12)
                .interactiveDismissDisabledPlus(false)
            }
        )
    }
}

struct SheetV2Example: View {
    @EnvironmentObject var settings: SheetSettings

    var body: some View {
        VStack {
            Text("Hello, World!")

            Text("Is Presented, \(settings.isPresented ? "True" : "False")")

            Button("Test") {
                settings.isPresented = !settings.isPresented
            }
        }
    }
}

#Preview {
    SheetV2Example()
}
