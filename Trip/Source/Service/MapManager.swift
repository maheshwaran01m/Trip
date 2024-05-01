//
//  MapManager.swift
//  Trip
//
//  Created by MAHESHWARAN on 21/04/24.
//

import MapKit
import SwiftData

enum MapManager {
  
  static func searchPlaces(_ context: ModelContext, searchText: String,
                           visibleRegion: MKCoordinateRegion?) async {
    
    removeSearchResults(context)
    
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = searchText
    
    if let visibleRegion {
      request.region = visibleRegion
    }
    
    let searchTerm = try? await MKLocalSearch(request: request).start()
    
    let results = searchTerm?.mapItems ?? []
    
    results.forEach {
      let mtPlacehmark = MTPlacemark(
        name: $0.placemark.name ?? "",
        address: $0.placemark.title ?? "",
        latitude: $0.placemark.coordinate.latitude,
        longitude: $0.placemark.coordinate.longitude
      )
      
      context.insert(mtPlacehmark)
    }
  }
  
  static func removeSearchResults(_ context: ModelContext) {
    let searchPredicate = #Predicate<MTPlacemark> { $0.destination == nil }
    
    try? context.delete(model: MTPlacemark.self, where: searchPredicate)
  }
  
  static func distance(meters: Double) -> String {
    let userLocale = Locale.current
    let formatter = MeasurementFormatter()
    
    var options: MeasurementFormatter.UnitOptions = []
    options.insert(.providedUnit)
    options.insert(.naturalScale)
    formatter.unitOptions = options
    
    let meterValue = Measurement(value: meters, unit: UnitLength.meters)
    let yardsValue = Measurement(value: meters, unit: UnitLength.yards)
    
    return formatter.string(from: userLocale.measurementSystem == .metric ? meterValue : yardsValue)
  }
}
