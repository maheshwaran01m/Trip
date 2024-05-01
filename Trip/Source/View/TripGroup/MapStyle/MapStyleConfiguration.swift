//
//  MapStyleConfiguration.swift
//  Trip
//
//  Created by MAHESHWARAN on 21/04/24.
//

import SwiftUI
import MapKit

struct MapStyleConfiguration {
  
  enum Style: CaseIterable {
    case standard, hybrid, imagery
    
    var label: String {
      switch self {
      case .standard: "Standard"
      case .hybrid: "Satellite with roads"
      case .imagery: "Satellite Only"
      }
    }
  }
  
  enum Elevation {
    case flat, realistic
    
    var selection: MapStyle.Elevation {
      switch self {
      case .flat: return .flat
      case .realistic: return .realistic
      }
    }
  }
  
  enum MapPOI {
    case all, excludingAll
    
    var selection: PointOfInterestCategories {
      switch self {
      case .all: return .all
      case .excludingAll: return .excludingAll
      }
    }
  }
  
  var baseStyle = Style.standard
  var elevation = Elevation.flat
  var pointsOfInterest = MapPOI.excludingAll
  
  
  var showTraffic = false
  
  var style: MapStyle {
    switch baseStyle {
    case .standard: 
      return MapStyle.standard(
      elevation: elevation.selection,
      pointsOfInterest: pointsOfInterest.selection,
      showsTraffic: showTraffic)
      
    case .hybrid:
      return MapStyle.hybrid(
      elevation: elevation.selection,
      pointsOfInterest: pointsOfInterest.selection,
      showsTraffic: showTraffic)
      
    case .imagery:
      return MapStyle.imagery(elevation: elevation.selection)
    }
  }
}
