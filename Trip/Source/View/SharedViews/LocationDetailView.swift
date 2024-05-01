//
//  LocationDetailView.swift
//  Trip
//
//  Created by MAHESHWARAN on 21/04/24.
//

import SwiftUI
import MapKit
import SwiftData

struct LocationDetailView: View {
  
  @SwiftUI.Environment(\.dismiss) private var dismiss
  
  var destination: Destination?
  var selectedPlacemark: MTPlacemark?
  
  @State private var name = ""
  @State private var address = ""
  
  @State private var lookaroundScene: MKLookAroundScene?
  
  @Binding private var showRoute: Bool
  
  @Binding var travelInterval: TimeInterval?
  @Binding var transportType: MKDirectionsTransportType
  
  init(destination: Destination? = nil,
       selectedPlacemark: MTPlacemark?,
       showRoute: Binding<Bool> = .constant(false),
       travelInterval: Binding<TimeInterval?> = .constant(nil),
       transportType: Binding<MKDirectionsTransportType> = .constant(.automobile)) {
    
    self.destination = destination
    self.selectedPlacemark = selectedPlacemark
    
    _showRoute = showRoute
    _travelInterval = travelInterval
    _transportType = transportType
  }
  
  var isChanged: Bool {
    guard let selectedPlacemark else { return false }
    
    return (name != selectedPlacemark.name) || (address != selectedPlacemark.address)
  }

  var body: some View {
    VStack {
      HStack(alignment: .top) {
        
        VStack(alignment: .leading) {
          
          if destination != nil {
            TextField("Name", text: $name)
            
            TextField("Address", text: $address, axis: .vertical)
            
            updateButtonView
          } else {
            Text(selectedPlacemark?.name ?? "")
              .font(.title2)
              .fontWeight(.semibold)
            
            Text(selectedPlacemark?.address ?? "")
              .font(.footnote)
              .foregroundStyle(.secondary)
              .lineLimit(2)
              .fixedSize(horizontal: false, vertical: true)
              .padding(.trailing)
          }
          
          if destination == nil {
            HStack {
              
              Button {
                transportType = .automobile
              } label: {
                Image(systemName: "car")
                  .symbolVariant(transportType == .automobile ? .circle : .none)
                  .imageScale(.large)
              }
              
              Button {
                transportType = .walking
              } label: {
                Image(systemName: "figure.walk")
                  .symbolVariant(transportType == .walking ? .circle : .none)
                  .imageScale(.large)
              }
              if let travelTime {
                let prefix = transportType == .automobile ? "Driving" : "Walking"
                
                Text("\(prefix) time: \(travelTime)")
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
            }
          }
        }
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
      }
      placeholderView
      addButtonView
    }
    .padding(8)
    .frame(maxHeight: .infinity, alignment: .top)
    .safeAreaInset(edge: .top, alignment: .trailing, content: closeButtonView)
    .onAppear(perform: onAppearAction)
    .task(id: selectedPlacemark) { await fetchLookAroundPreview() }
  }
  
  
  private func closeButtonView() -> some View {
    Button { dismiss() } label: {
      Image(systemName: "xmark.circle.fill")
        .imageScale(.large)
        .foregroundStyle(.gray)
    }
    .padding(8)
  }
  
  private var addButtonView: some View {
    HStack {
      if let destination {
        
        let isList = selectedPlacemark?.destination != nil
        
        Button {
          if let selectedPlacemark {
            if selectedPlacemark.destination == nil {
              destination.placemarks.append(selectedPlacemark)
            } else {
              selectedPlacemark.destination = nil
            }
            dismiss()
          }
        } label: {
          Label(isList ? "Remove" : "Add", systemImage: isList ? "minus.circle" : "plus.circle")
        }
        .buttonStyle(.borderedProminent)
        .tint(isList ? .red : .green)
        .disabled(name.isEmpty || isChanged)
        .frame(maxWidth: .infinity, alignment: .trailing)
      } else {
        
        HStack(spacing: 8) {
          Button("Open in maps", systemImage: "map") {
            guard let selectedPlacemark else { return }
            
            let placemark = MKPlacemark(coordinate: selectedPlacemark.coordinate)
            
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = selectedPlacemark.name
            mapItem.openInMaps()
          }
          .fixedSize(horizontal: true, vertical: false)
          
          Button("Show Route", systemImage: "location.north") {
            showRoute.toggle()
          }
          .fixedSize(horizontal: true, vertical: false)
        }
        .buttonStyle(.bordered)
      }
    }
  }
  
  @ViewBuilder
  private var updateButtonView: some View {
    if isChanged {
      Button("Update") {
        selectedPlacemark?.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        selectedPlacemark?.address = address.trimmingCharacters(in: .whitespacesAndNewlines)
      }
      .frame(maxWidth: .infinity, alignment: .trailing)
      .buttonStyle(.borderedProminent)
    }
  }
  
  @ViewBuilder
  private var placeholderView: some View {
    if let lookaroundScene {
      LookAroundPreview(initialScene: lookaroundScene)
        .frame(height: 200)
        .padding(8)
    } else {
      ContentUnavailableView("No Preview available", systemImage: "eye.slash")
    }
  }
  
  // MARK: - Methods
  
  private func onAppearAction() {
    guard let selectedPlacemark, destination != nil else {
      return
    }
    name = selectedPlacemark.name
    address = selectedPlacemark.address
  }
  
  func fetchLookAroundPreview() async {
    guard let selectedPlacemark else { return }
    lookaroundScene = nil
    
    let lookAroundRequest = MKLookAroundSceneRequest(
      coordinate: selectedPlacemark.coordinate)
    
    lookaroundScene = try? await lookAroundRequest.scene
  }
  
  var travelTime: String? {
    guard let travelInterval else { return nil }
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .abbreviated
    formatter.allowedUnits = [.hour, .minute]
    
    return formatter.string(from: travelInterval)
  }
}

// MARK: - Preview

#Preview("Destination Tap") {
  let container = Destination.preview
  let fetch = FetchDescriptor<Destination>()
  
  let destination = try! container.mainContext.fetch(fetch)[0]
  let selectedPlacemark = destination.placemarks[0]
  
  return LocationDetailView(destination: destination,
                            selectedPlacemark: selectedPlacemark)
}

#Preview("Trip Map") {
  let container = Destination.preview
  let fetch = FetchDescriptor<MTPlacemark>()
  
  let placemarks = try! container.mainContext.fetch(fetch)
  let selectedPlacemark = placemarks[0]
  
  return LocationDetailView(selectedPlacemark: selectedPlacemark)
}
