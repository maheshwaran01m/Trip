//
//  TripMapView.swift
//  Trip
//
//  Created by MAHESHWARAN on 21/04/24.
//

import MapKit
import SwiftUI
import SwiftData

struct TripMapView: View {
  
  @Environment(\.modelContext) private var modelContext
  
  @Environment(LocationManager.self) var locationManager
  
  @State private var position = MapCameraPosition.userLocation(fallback: .automatic)
  
  @State private var visiblePosition: MKCoordinateRegion?
  
  @Query private var listPlacemarks: [MTPlacemark]
  
  // Search
  @State private var searchText = ""
  
  @FocusState private var searchFieldFocus: Bool
  
  @Query(filter: #Predicate<MTPlacemark> { $0.destination == nil} ) private var searchPlacemarks: [MTPlacemark]
  
  @State private var selectedPlacemark: MTPlacemark?
  
  // Route
  
  @State private var showRoute = false
  
  @State private var routeDisplaying = false
  @State private var route: MKRoute?
  @State private var routeDestination: MKMapItem?
  @State private var travelInterval: TimeInterval?
  @State private var transportType = MKDirectionsTransportType.automobile
  
  @State private var showSteps = false
  
  // Map Scope
  @Namespace private var mapScope
  
  // Map Style
  
  @State private var mapStyle = MapStyleConfiguration()
  
  @State private var showMapStyle = false
  
  // MARK: - View
  
  var body: some View {
    mapView
  }
  
  private var mapView: some View {
    Map(position: $position, selection: $selectedPlacemark,
        scope: mapScope, content: mapContent)
    .mapControls(mapControl)
    .mapStyle(mapStyle.style)
    
    .onMapCameraChange(frequency: .onEnd) {
      visiblePosition = $0.region
    }
    .onAppear(perform: updateCameraPosition)
    .safeAreaInset(edge: .bottom, content: bottomView)
    .sheet(item: $selectedPlacemark) { placemark in
      
      LocationDetailView(
        selectedPlacemark: placemark,
        showRoute: $showRoute,
        travelInterval: $travelInterval,
        transportType: $transportType)
        .presentationDetents([.height(450)])
        .presentationDragIndicator(.visible)
    }
    
    .task(id: selectedPlacemark) {
      if selectedPlacemark != nil {
        routeDisplaying = false
        showRoute = false
        route = nil
        
        await fetchRoute()
      }
    }
    .task(id: transportType) { await fetchRoute() }
    .onChange(of: showRoute) {
      selectedPlacemark = nil
      if showRoute {
        withAnimation {
          routeDisplaying = true
          
          if let rect = route?.polyline.boundingMapRect {
            position = .rect(rect)
          }
        }
      }
    }
    .mapScope(mapScope)
  }
  
  @ViewBuilder
  private func mapControl() -> some View {
//    MapUserLocationButton()
//    MapCompass()
//    MapPitchToggle()
    MapScaleView()
  }
  
  @MapContentBuilder
  private func mapContent() -> some MapContent {
//    UserAnnotation()
    
    UserAnnotation {
      Image(systemName: "location.circle")
        .imageScale(.large)
        .foregroundStyle(.blue)
    }
    
    ForEach(listPlacemarks) { placemark in
      if !showRoute {
        Group {
          if placemark.destination != nil {
            Marker(coordinate: placemark.coordinate) {
              Label(placemark.name, systemImage: "star")
            }
            .tint(.yellow)
          } else {
            Marker(placemark.name, coordinate: placemark.coordinate)
          }
        }.tag(placemark)
      } else {
        
        if let routeDestination {
          Marker(item: routeDestination)
            .tint(.green)
        }
      }
    }
    
    if let route, routeDisplaying {
      MapPolyline(route.polyline)
        .stroke(.blue, lineWidth: 6)
    }
  }
  
  func updateCameraPosition() {
    clearSearchResults()
    
    guard let userLocation = locationManager.userLocation else { 
      return
    }
    let userRegion = MKCoordinateRegion(
      center: userLocation.coordinate,
      span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15))
    
    withAnimation {
      position = .region(userRegion)
    }
  }
}

// MARK: - Search

extension TripMapView {
  
  private func bottomView() -> some View {
    HStack(alignment: .bottom, spacing: 4) {
      VStack {
        searchBarView
        clearRouteView
      }
      clearButtonView
    }
    .padding(8)
  }
  
  @ViewBuilder
  private var searchBarView: some View {
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
        }
      }
  }
  
  private func clearSearchResults() {
    MapManager.removeSearchResults(modelContext)
  }
  
  private var clearButtonView: some View {
    VStack(spacing: 8) {
      if !searchPlacemarks.isEmpty {
        Button(action: clearSearchResults) {
          Image(systemName: "mappin.slash")
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
      }
      
      Button {
        showMapStyle.toggle()
      } label: {
        Image(systemName: "globe.americas.fill")
          .imageScale(.large)
      }
      .padding(8)
      .background(.thickMaterial)
      .clipShape(.circle)
      .sheet(isPresented: $showMapStyle) {
        MapStyleView(mapStyle: $mapStyle)
          .presentationDetents([.height(275)])
          .presentationDragIndicator(.visible)
      }
      
      MapUserLocationButton(scope: mapScope)
      
      MapCompass(scope: mapScope)
        .mapControlVisibility(.visible)
      
      MapPitchToggle(scope: mapScope)
        .mapControlVisibility(.visible)
    }
    .buttonBorderShape(.circle)
  }
  
  @ViewBuilder
  private var clearRouteView: some View {
    if routeDisplaying {
      HStack {
        Button("Clear Route", systemImage: "xmark.cirlce",
               action: removeRoute)
        .buttonStyle(.borderedProminent)
        .fixedSize(horizontal: true, vertical: false)
        
        Button("Show Steps", systemImage: "location.north") {
          showSteps.toggle()
        }
        .buttonStyle(.borderedProminent)
        .fixedSize(horizontal: true, vertical: false)
        .sheet(isPresented: $showSteps, content: stepsView)
      }
    }
  }
  
  @ViewBuilder
  private func stepsView() -> some View {
    if let route {
      NavigationStack {
        
        List {
          HStack {
            Image(systemName: "mappin.circle.fill")
              .foregroundStyle(.red)
            
            Text("From my location")
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          
          ForEach(1..<route.steps.count, id: \.self) { index in
            
            VStack(alignment: .leading) {
              Text("\(transportType == .automobile ? "Drive" : "Walk") \(MapManager.distance(meters: route.steps[index].distance))")
                .bold()
              
              Text(" - \(route.steps[index].instructions)")
            }
          }
        }
        .listStyle(.plain)
        .navigationTitle("Steps")
        .navigationBarTitleDisplayMode(.inline)
      }
      .presentationDragIndicator(.visible)
    }
  }
}

// MARK: - Route

extension TripMapView {
  
  func fetchRoute() async {
    guard let userLocation = locationManager.userLocation,
          let selectedPlacemark else { return }
    
    let request = MKDirections.Request()
    let sourcePlacemark = MKPlacemark(coordinate: userLocation.coordinate)
    
    let routeSource = MKMapItem(placemark: sourcePlacemark)
    
    let destinationPlacemark = MKPlacemark(coordinate: selectedPlacemark.coordinate)
    
    routeDestination = MKMapItem(placemark: destinationPlacemark)
    routeDestination?.name = selectedPlacemark.name
    
    request.source = routeSource
    request.destination = routeDestination
    request.transportType = transportType
    
    let directions = MKDirections(request: request)
    
    let results = try? await directions.calculate()
    
    route = results?.routes.first
    
    travelInterval = route?.expectedTravelTime
  }
  
  func removeRoute() {
    routeDisplaying = false
    showRoute = false
    route = nil
    selectedPlacemark = nil
    
    updateCameraPosition()
  }
}

// MARK: - Preview

#Preview {
  
  return TripMapView()
    .environment(LocationManager())
    .modelContainer(Destination.preview)
  
  // To Request location permission
  struct PreviewView: View {
    
    let manager = CLLocationManager()
    
    var body: some View {
      Map() {
        UserAnnotation()
      }
      .onAppear { manager.requestWhenInUseAuthorization() }
    }
  }
}
