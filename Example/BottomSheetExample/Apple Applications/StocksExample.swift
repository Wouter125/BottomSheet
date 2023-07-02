//
//  Stocks.swift
//  BottomSheetExample
//
//  Created by Wouter van de Kamp on 04/12/2022.
//

import SwiftUI
import BottomSheet

struct StocksExample: View {
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
                    settings.activeSheetType = .stocks
                }
        }
    }
}

struct StocksHeader: View {
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Business News")
                        .font(.title)
                        .fontWeight(.heavy)
                    Text("From Yahoo Finance")
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
                .padding(.top, 10)
                .padding(.bottom, 16)

                Spacer()
            }

            Divider()
             .frame(height: 1)
             .background(Color(UIColor.systemGray6))
        }
        .padding(.top, 8)
        .padding(.horizontal, 16)
    }
}

struct StocksMainContent: View {
    var body: some View {
        VStack(spacing: 0) {
            TextField("Test", text: .constant(""))
            ScrollView {
                ForEach(0..<5, id: \.self) { _ in
                    newsRow
                }
            }
            Spacer(minLength: 72)
        }
    }

    var newsRow: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("FX Empire")
                        .font(.caption)
                        .foregroundColor(Color(UIColor.secondaryLabel))

                    Text("Bitcoin (BTC) treads water after brief visit to sub-$39,000")
                        .font(.headline)
                        .foregroundColor(Color(UIColor.label))

                    Text("While Bitcoin (BTC) struggled on Saturday, XRP")
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .lineLimit(1)
                }
                .padding(.vertical, 16)

                Spacer()
            }

            HStack {
                Text("13h ago")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color(UIColor.secondaryLabel))

                Spacer()
            }
        }
        .padding(.horizontal, 16)
    }
}

struct StocksExample_Previews: PreviewProvider {
    static var previews: some View {
        StocksExample()
    }
}
