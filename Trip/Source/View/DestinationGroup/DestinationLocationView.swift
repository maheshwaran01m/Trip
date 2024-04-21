//
//  DestinationLocationView.swift
//  Trip
//
//  Created by MAHESHWARAN on 21/04/24.
//

import SwiftUI
import SwiftData
import MapKit

struct DestinationLocationView: View {
  
  @State private var position: MapCameraPosition = .automatic
  
  @State private var visiblePosition: MKCoordinateRegion?
  
  @Query private var destinations: [Destination]
  
  @State private var destination: Destination?
  
  var body: some View {
    Map(position: $position, content: mapContent)
      .onMapCameraChange(frequency: .onEnd) {
        visiblePosition = $0.region
      }
      .onAppear(perform: destinationAction)
  }
  
  // MARK: - Map Content
  
  @MapContentBuilder
  private func mapContent() -> some MapContent {
    if let destination {
      
      ForEach(destination.placemarks) { placemark in
        
        Marker(coordinate: placemark.coordinate) {
          Label(placemark.name, systemImage: "star")
        }
      }
    }
  }
  
  // MARK: - Marker
  
  private func destinationAction() {
    guard let destination = destinations.first,
          let region = destination.region else {
      return
    }
    self.destination = destination
    position = .region(region)
  }
}

// MARK: - Map Content

extension DestinationLocationView {
  
  var mapContentView: some View {
    Map(position: $position, content: exampleMapContent)
    .onAppear(perform: mapPosition)
    .onMapCameraChange(frequency: .onEnd) {
      visiblePosition = $0.region
    }
  }
  
  // MARK: Marker
  
  @MapContentBuilder
  private func exampleMapContent() -> some MapContent {
    
    Marker("Moulin Rouge", coordinate: .init(latitude: 48.856788, longitude: 2.351077))
    
    Marker(coordinate: .init(latitude: 48.873776, longitude: 2.295043)) {
      Label("Arc de Triomplhe", systemImage: "star.fill")
    }
    .tint(.yellow)
    
    Marker("Gare du Nord", monogram: Text("GN"),
           coordinate: .init(latitude: 48.880071, longitude: 2.354977))
    .tint(.accent)
    
    Marker("Louvre", systemImage: "person.crop.artframe",
           coordinate: .init(latitude: 48.861950, longitude: 2.336902))
    .tint(.accentBlue)
    
    Annotation("Notre Dame", coordinate: .init(
      latitude: 48.852972, longitude: 2.350004)) {
      
        Image(systemName: "star")
          .imageScale(.large)
          .foregroundStyle(.red)
          .padding(8)
          .background(.white)
          .clipShape(.circle)
    }
    
    Annotation("Scare Coeur",
               coordinate: .init(latitude: 48.886634, longitude: 2.343048),
               anchor: .center) {
      Image(systemName: "star.fill")
        .resizable()
        .scaledToFit()
        .foregroundStyle(.yellow)
        .frame(width: 24, height: 24)
    }
    
    Annotation("Pantheon",
               coordinate: .init(latitude: 48.845616, longitude: 2.345996)) {
      Image(systemName: "mappin")
        .imageScale(.large)
        .foregroundStyle(.red)
        .padding(5)
        .overlay {
          Circle()
            .strokeBorder(.red, lineWidth: 2)
        }
    }
    
    MapCircle(center: .init(latitude: 48.856788, longitude: 2.351077), radius: 5000)
      .foregroundStyle(.red.opacity(0.3))
  }
  
  // MARK: Position
  
  private func mapPosition() {
    // 48.856788, 2.351077
    let point = CLLocationCoordinate2D(latitude: 48.856788, longitude: 2.351077)
    
    let span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    
    let region = MKCoordinateRegion(center: point, span: span)
    
    position = .region(region)
  }
}

// MARK: - Preview

#Preview {
  DestinationLocationView()
    .modelContainer(Destination.preview)
}
