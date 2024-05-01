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
  
  @Environment(\.modelContext) private var modelContext
  
  @State private var position: MapCameraPosition = .automatic
  
  @State private var visiblePosition: MKCoordinateRegion?
  
  @Bindable var selectedDestination: Destination
  
  @State private var selectedPlacemark: MTPlacemark?
  
  @State private var searchText = ""
  
  @FocusState private var searchFieldFocus: Bool
  
  @Query(filter: #Predicate<MTPlacemark> { $0.destination == nil} ) private var searchPlacemarks: [MTPlacemark]
  
  private var listPlacemarks: [MTPlacemark] {
    searchPlacemarks + destination.placemarks
  }
  
  private var destination: Destination
  
  @State private var isManualMarker = false
  
  // MARK: - Init
  
  init(for destination: Destination) {
    self.destination = destination
    _selectedDestination = .init(destination)
  }
  
  // MARK: - View
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      labelView
      messageView
      mapReaderView
    }
    .navigationTitle("Destination")
    .navigationBarTitleDisplayMode(.inline)
    .safeAreaInset(edge: .bottom, content: bottomView)
    .onDisappear(perform: clearSearchResults)
  }
  
  // MARK: - Main View
  
  private var mapReaderView: some View {
    MapReader { proxy in
      mapView
        .onTapGesture { position in
          guard isManualMarker,
                let coordinate = proxy.convert(position, from: .local) else {
            return
          }
          
          let placemark = MTPlacemark(
            name: "",
            address: "",
            latitude: coordinate.latitude,
            longitude: coordinate.longitude)
          
          modelContext.insert(placemark)
          selectedPlacemark = placemark
        }
    }
  }
  
  private var mapView: some View {
    Map(position: $position, selection: $selectedPlacemark, content: mapContent)
      .onMapCameraChange(frequency: .onEnd) {
        visiblePosition = $0.region
      }
      .onAppear(perform: onAppearAction)
      .sheet(item: $selectedPlacemark, onDismiss: {
        if isManualMarker {
          MapManager.removeSearchResults(modelContext)
        }
      }) { placemark in
        LocationDetailView(destination: destination, selectedPlacemark: placemark)
          .presentationDetents([.height(450)])
      }
  }
  
  // MARK: - Label
  
  private var labelView: some View {
    LabeledContent {
      TextField("Enter destination title", text: $selectedDestination.name)
        .textFieldStyle(.roundedBorder)
        .foregroundStyle(.primary)
      
    } label: {
      Text("Title")
    }
    .padding()
  }
  
  private var messageView: some View {
    HStack {
      Text("Adjust the map to se the region for your destinations")
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
      
      Button("Set region") {
        guard let visiblePosition else { return }
        
        selectedDestination.latitude = visiblePosition.center.latitude
        selectedDestination.longitude = visiblePosition.center.longitude
        selectedDestination.latitudeDelta = visiblePosition.span.latitudeDelta
        selectedDestination.longitudeDelta = visiblePosition.span.longitudeDelta
      }
      .buttonStyle(.borderedProminent)
    }
    .padding(.horizontal)
  }
  
  // MARK: - Map Content
  
  @MapContentBuilder
  private func mapContent() -> some MapContent {
    ForEach(listPlacemarks) { placemark in
      
      if isManualMarker {
        
        if placemark.destination != nil {
          Marker(coordinate: placemark.coordinate) {
            Label(placemark.name, systemImage: "star")
          }
        } else {
          Marker(placemark.name, coordinate: placemark.coordinate)
            .tint(.orange)
        }
      } else {
        
        Group {
          if placemark.destination != nil {
            Marker(coordinate: placemark.coordinate) {
              Label(placemark.name, systemImage: "star")
            }
          } else {
            Marker(placemark.name, coordinate: placemark.coordinate)
              .tint(.orange)
          }
        }
        .tag(placemark)
      }
    }
  }
  
  // MARK: - Marker
  
  private func onAppearAction() {
    clearSearchResults()
    
    guard let region = destination.region else {
      return
    }
    position = .region(region)
  }
}

// MARK: - Bottom Bar

extension DestinationLocationView {
  
  private func bottomView() -> some View {
    VStack {
      markerView
      searchBarView
    }
  }
  
  private var markerView: some View {
    Toggle(isOn: $isManualMarker) {
      Label("Create New marker Placement is: \(isManualMarker ? "On" : "Off")", systemImage: isManualMarker ? "mappin.circle" : "mappin.slash.circle")
    }
    .fontWeight(.bold)
    .toggleStyle(.button)
    .background(.ultraThinMaterial)
    .clipShape(.capsule)
    .onChange(of: isManualMarker) { _, _ in
      MapManager.removeSearchResults(modelContext)
    }
  }
}

// MARK: - Search

extension DestinationLocationView {
  
  @ViewBuilder
  private var searchBarView: some View {
    if !isManualMarker {
      HStack {
        TextField("Search...", text: $searchText)
          .textFieldStyle(.roundedBorder)
          .clipShape(.rect(cornerRadius: 16))
          .background {
            RoundedRectangle(cornerRadius: 16)
              .stroke(lineWidth: 2)
          }
          .autocorrectionDisabled()
          .textInputAutocapitalization(.never)
          .focused($searchFieldFocus)
          .overlay(alignment: .trailing) {
            if searchFieldFocus && !searchText.isEmpty {
              Button {
                searchText = ""
                searchFieldFocus = false
              } label: {
                Image(systemName: "xmark.circle.fill")
              }
              .padding(.trailing, 4)
            }
          }
          .onSubmit {
            Task {
              await MapManager.searchPlaces(
                modelContext,
                searchText: searchText,
                visibleRegion: visiblePosition)
              
              searchText = ""
              position = .automatic
            }
          }
        
        if !searchPlacemarks.isEmpty {
          Button {
            MapManager.removeSearchResults(modelContext)
          } label: {
            Image(systemName: "mappin.slash.circle.fill")
          }
          .foregroundStyle(.white)
          .padding(8)
          .background(.blue)
          .clipShape(.circle)
        }
      }
      .padding()
    }
  }
  
  private func clearSearchResults() {
    MapManager.removeSearchResults(modelContext)
  }
}

// MARK: - Preview

#Preview {
  
  let container = Destination.preview
  let fetch = FetchDescriptor<Destination>()
  
  let destinations = try! container.mainContext.fetch(fetch)
  let destination = destinations[0]
  
  return NavigationStack {
    DestinationLocationView(for: destination)
  }
  .modelContainer(Destination.preview)
  
  // MARK: - Example Query
  
  /*
   return PreviewExampleView()
   .modelContainer(Destination.preview)
   */
  
  struct PreviewExampleView: View {
    
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
    
    // MARK: - Map Content Example
    
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
}
