//
//  LocationManager.swift
//  Trip
//
//  Created by MAHESHWARAN on 21/04/24.
//

import SwiftUI
import CoreLocation

@Observable
class LocationManager: NSObject {
  
  @ObservationIgnored let manager = CLLocationManager()
  
  var userLocation: CLLocation?
  var isAuthorized = false
  
  override init() {
    super.init()
    manager.delegate = self
    startLocationServices()
  }
  
  private func startLocationServices() {
    guard manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways else {
      
      isAuthorized = false
      manager.requestWhenInUseAuthorization()
      return
    }
    manager.startUpdatingLocation()
    isAuthorized =  true
  }
}

extension LocationManager: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager,
                       didUpdateLocations locations: [CLLocation]) {
    userLocation = locations.last
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    switch manager.authorizationStatus {
      
    case .authorizedAlways, .authorizedWhenInUse:
      isAuthorized = true
      manager.requestWhenInUseAuthorization()
    
    case .notDetermined:
      isAuthorized = false
      manager.requestWhenInUseAuthorization()
    
    case .denied:
      isAuthorized = false
      
    default:
      isAuthorized = true
      startLocationServices()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    debugPrint("Location Manager Error, reason: \(error.localizedDescription)")
  }
}
