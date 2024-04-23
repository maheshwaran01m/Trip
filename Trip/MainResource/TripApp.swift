//
//  TripApp.swift
//  Trip
//
//  Created by MAHESHWARAN on 21/04/24.
//

import SwiftUI
import SwiftData

@main
struct TripApp: App {
  
  @State private var locationManager = LocationManager()
  
  var body: some Scene {
    WindowGroup(content: mainView)
      .modelContainer(for: Destination.self)
      .environment(locationManager)
  }
  
  @ViewBuilder
  private func mainView() -> some View {
    if locationManager.isAuthorized {
      ContentView()
    } else {
      LocationDeniedView()
    }
  }
}
