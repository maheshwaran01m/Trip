//
//  Destination.swift
//  Trip
//
//  Created by MAHESHWARAN on 21/04/24.
//

import SwiftData
import MapKit

@Model
class Destination {
  
  var name: String
  var latitude: Double?
  var longitude: Double?
  var latitudeDelta: Double?
  var longitudeDelta: Double?
  
  @Relationship(deleteRule: .cascade) var placemarks = [MTPlacemark]()
  
  init(name: String,
       latitude: Double? = nil,
       longitude: Double? = nil,
       latitudeDelta: Double? = nil,
       longitudeDelta: Double? = nil) {
    
    self.name = name
    self.latitude = latitude
    self.longitude = longitude
    self.latitudeDelta = latitudeDelta
    self.longitudeDelta = longitudeDelta
  }
}

extension Destination {
  
  var region: MKCoordinateRegion? {
    guard let latitude, let longitude, let latitudeDelta, let longitudeDelta else { return nil }
    
    return MKCoordinateRegion(
      center: .init(latitude: latitude, longitude: longitude),
      span: .init(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
  }
}

// MARK: - Preview

extension Destination {
  
  @MainActor
  static var preview: ModelContainer {
    
    let container = try! ModelContainer(
      for: Destination.self,
      configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    let destination = Destination(
      name: "Paris",
      latitude: 48.856788,
      longitude: 2.351077,
      latitudeDelta: 0.15,
      longitudeDelta: 0.15)
    
    var placemarks: [MTPlacemark] {
      [ .init(name: "Louvre Museum", address: "93 Rue de Rivoli, 75001 Paris, France", latitude: 48.861950, longitude: 2.336902),
        .init(name: "Sacré-Coeur Basilica", address: "Parvis du Sacré-Cœur, 75018 Paris, France", latitude: 48.886634, longitude: 2.343048),
        .init(name: "Eiffel Tower", address: "5 Avenue Anatole France, 75007 Paris, France", latitude: 48.858258, longitude: 2.294488),
        .init(name: "Moulin Rouge", address: "82 Boulevard de Clichy, 75018 Paris, France", latitude: 48.884134, longitude: 2.332196),
        .init(name: "Arc de Triomphe", address: "Place Charles de Gaulle, 75017 Paris, France", latitude: 48.873776, longitude: 2.295043),
        .init(name: "Gare Du Nord", address: "Paris, France", latitude: 48.880071, longitude: 2.354977),
        .init(name: "Notre Dame Cathedral", address: "6 Rue du Cloître Notre-Dame, 75004 Paris, France", latitude: 48.852972, longitude: 2.350004),
        .init(name: "Panthéon", address: "Place du Panthéon, 75005 Paris, France", latitude: 48.845616, longitude: 2.345996),
      ]
    }
    
    container.mainContext.insert(destination)
    
    placemarks.forEach { destination.placemarks.append($0) }
    
    return container
  }
}
