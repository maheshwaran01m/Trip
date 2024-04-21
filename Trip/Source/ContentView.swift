//
//  ContentView.swift
//  Trip
//
//  Created by MAHESHWARAN on 21/04/24.
//

import SwiftUI

struct ContentView: View {
  
  var body: some View {
    TabView {
      mainView
    }
  }
  
  private var mainView: some View {
    Group {
      tripMapView
      destinationLocationView
    }
    .toolbarBackground(Color.accentBlue.opacity(0.5), for: .tabBar)
    .toolbarBackground(.visible, for: .tabBar)
    .toolbarColorScheme(.dark, for: .tabBar)
  }
  
  private var tripMapView: some View {
    TripMapView()
      .tabItem {
        Label("Trip", systemImage: "map")
      }
  }
  
  private var destinationLocationView: some View {
    DestinationLocationView()
      .tabItem {
        Label("Destination", systemImage: "globe.desk")
      }
  }
}

// MARK: - Preview

#Preview {
  ContentView()
}
