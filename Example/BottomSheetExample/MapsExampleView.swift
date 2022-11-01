//
//  MapsExampleView.swift
//  BottomSheetExample
//
//  Created by Wouter van de Kamp on 21/07/2022.
//

import SwiftUI
import UIKit
import MapKit
import BottomSheet

// Not 1:1 with the actual Maps UI because
// we are using an extended navigation bar
enum MapsBottomSheetPositions: CGFloat, CaseIterable {
    case bottom = 0.12
    case middle = 0.47
    case top = 0.875
}

struct Item: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let isMoveDisabled: Bool
}

struct MapsExampleView: View {
    @State var locations: [Item] = [
        Item(
            name: "My Location",
            icon: "location.circle.fill",
            isMoveDisabled: false
        ),
        Item(
            name: "Brooklyn",
            icon: "mappin.circle.fill",
            isMoveDisabled: false
        ),
        Item(
            name: "Add Stop",
            icon: "plus.circle.fill",
            isMoveDisabled: true
        )
    ]
    
    @State var position: MapsBottomSheetPositions = .middle
    @State var editMode: EditMode = .active
    @State var isPanelDraggable = true
    
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 40.7166487241336,
            longitude: -74.00701228370755
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.2,
            longitudeDelta: 0.2
        )
    )
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $mapRegion)
                .ignoresSafeArea()
            
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
                                .foregroundColor(Color(UIColor.systemGray2))
                                .cornerRadius(2.5)
                        })

                        HStack(alignment: .center) {
                            Text("Directions")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                            Button {
                                print("Close sheet")
                            } label: {
                                Image(systemName: "xmark")
                                    .font(Font.system(size: 15, weight: .bold))
                                    .foregroundColor(.secondary)
                            }
                            .frame(
                                width: 30,
                                height: 30,
                                alignment: .center
                            )
                            .background(
                                Color(UIColor.systemGray5)
                            )
                            .cornerRadius(16)
                        }
                        .padding(.top, 6)
                        .padding(.bottom, 16)
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                },
                content: {
                    EmptyView()
                    VStack {
                        inputFields
                        tags
                        emptyState
                    }
                }
            )
            .isDraggable(isPanelDraggable)
            .background(
                Color.white
//                Blur(style: .systemThickMaterial)
//                    .cornerRadius(
//                        8,
//                        corners: [.topLeft, .topRight]
//                    )
//                    .zIndex(0)
            )
            .shadow(
                color: Color.black.opacity(0.16),
                radius: 2, y: -1
            )
        }
        .navigationBarTitle("", displayMode: .inline)
//        .overlay(alignment: .top, content: {
//            Color.clear
//                .background(Blur(style: .systemUltraThinMaterial))
//                .edgesIgnoringSafeArea(.top)
//                .frame(height: 0)
//        })
    }
    
    var inputFields: some View {
        List {
            ForEach(locations) { item in
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: item.icon)
                        .foregroundColor(.secondary)
                    Text(item.name)
                }
                .listRowBackground(Color(UIColor.tertiarySystemFill))
                .moveDisabled(item.isMoveDisabled)
            }
            .onMove { source, destination in
                locations.move(
                    fromOffsets: source,
                    toOffset: destination
                )
            }
        }
//        .onAppear {
//            UITableView.appearance().backgroundColor = .clear
//            UICollectionView.appearance().backgroundColor = .clear
//        }
        .frame(maxHeight: 172)
        .environment(\.editMode, $editMode)
    }
    
    var tags: some View {
        HStack {
            Menu {
                Button("Driving", action: {})
                Button("Walking", action: {})
                Button("Transit", action: {})
                Button("Cycling", action: {})
                Button("Ride", action: {})
            } label: {
                HStack(spacing: 8) {
                    Label("Driving", systemImage: "car.fill")
                        .foregroundColor(Color.white)
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                )
                
            }
        }
    }
    
    var emptyState: some View {
        VStack {
            Text("Directions Not Available")
                .fontWeight(.semibold)
            Text("Route information is not available at this moment.")
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 48)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        locations.move(fromOffsets: source, toOffset: destination)
    }
}

struct MapsExampleView_Previews: PreviewProvider {
    static var previews: some View {
        MapsExampleView()
    }
}


/// Causing issues with the components on the background, needs some attention
//struct Blur: UIViewRepresentable {
//    var style: UIBlurEffect.Style = .systemMaterial
//
//    func makeUIView(context: Context) -> UIVisualEffectView {
//        return UIVisualEffectView(effect: UIBlurEffect(style: style))
//    }
//
//    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
////        uiView.effect = UIBlurEffect(style: style)
//    }
//}
