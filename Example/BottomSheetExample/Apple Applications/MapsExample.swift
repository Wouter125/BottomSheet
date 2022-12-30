//
//  MapsExample.swift
//  BottomSheetExample
//
//  Created by Wouter van de Kamp on 28/12/2022.
//

import SwiftUI

struct MapsExample: View {
    @EnvironmentObject var settings: SheetSettings

    var body: some View {
        Color.clear
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("\(settings.translation.rounded())")
            .onAppear {
                settings.isPresented = true
                settings.activeSheetType = .maps
            }
    }
}

struct MapsHeader: View {
    @EnvironmentObject var settings: SheetSettings

    var body: some View {
        VStack {
            HStack {
                Text("Directions")
                    .font(.title)
                    .fontWeight(.heavy)

                Spacer()

                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .onTapGesture {
                        settings.isPresented = false
                    }
            }
            .padding(.top, 10)
            .padding(.bottom, 16)
        }
        .padding(.top, 8)
        .padding(.horizontal, 16)
    }
}

struct MapsMainContent: View {
    var body: some View {
        ScrollView {
            ForEach(0..<5, id: \.self) { _ in
                Text("Hallo")
            }
        }

    }
}

struct MapsExample_Previews: PreviewProvider {
    static var previews: some View {
        MapsExample()
    }
}
