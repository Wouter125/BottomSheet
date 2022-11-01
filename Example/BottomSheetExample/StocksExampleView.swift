//
//  ContentView.swift
//  BottomSheetExample
//
//  Created by Wouter van de Kamp on 10/03/2022.
//

import SwiftUI
import BottomSheet

enum StocksBottomSheetAbsolutePosition: CGFloat, CaseIterable {
    case bottom = 182
    case middle = 320
    case top = 700
}

enum StocksBottomSheetRelativePosition: CGFloat, CaseIterable {
    case bottom = 0.216
    case middle = 0.355
    case top = 0.829
}

struct StocksExampleView: View {
    @State var position: StocksBottomSheetRelativePosition = .middle

    var body: some View {
        ZStack(alignment: .bottom) {
            BottomSheetView(
                position: $position,
                header: {
                    VStack(spacing: 0) {
                        Button(action: {
                            if position != .top {
                                position = .top
                            } else {
                                position = .middle
                            }
                        }, label: {
                            Rectangle()
                                .frame(
                                    width: 36,
                                    height: 5,
                                    alignment: .center
                                )
                                .foregroundColor(Color(UIColor.systemGray3))
                                .cornerRadius(2.5)
                        })

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
                },
                content: {
                    VStack(spacing: 0) {
                        ScrollView {
                            ForEach(0..<12, id: \.self) { _ in
                                newsRow
                            }
                        }

                        Spacer(minLength: 54)
                    }
                    // Enable or disable the following line if we want to run the scrollview outside the safe-area
                    // .edgesIgnoringSafeArea([.bottom])
                }
            )
            .background(
                Color(UIColor.systemBackground)
                    .cornerRadius(
                        12,
                        corners: [.topLeft, .topRight]
                    )
            )
            .animationCurve(mass: 1, stiffness: 250)
            .snapThreshold(1.8)
            .onBottomSheetDrag { translation, modulated in
                print("Translation", translation, modulated)
            }

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
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea([.bottom])
            )
            .zIndex(1)
        }
        .navigationBarTitle("", displayMode: .inline)
        .background(
            Color(UIColor.systemFill)
        )
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

struct StocksExampleView_Previews: PreviewProvider {
    static var previews: some View {
        StocksExampleView()
    }
}