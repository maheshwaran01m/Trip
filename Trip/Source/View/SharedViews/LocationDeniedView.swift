//
//  LocationDeniedView.swift
//  Trip
//
//  Created by MAHESHWARAN on 21/04/24.
//

import SwiftUI

struct LocationDeniedView: View {
  
  var body: some View {
    ContentUnavailableView(label: {
      Label("Location Services", systemImage: "location.circle")
    }, description: {
      
      Text("""
           1. Tap the button below and go to "Privacy and Security"
           2. Tap on "Location Services"
           3. Locate the "Trip" app and tap on it,
           4. Change the settings to "While using the App"
           """)
      .multilineTextAlignment(.leading)
      
    }, actions: {
      if let url = URL(string: UIApplication.openSettingsURLString) {
        
        Link(destination: url) {
          Text("Open Settings")
        }
        .buttonStyle(.borderedProminent)
      }
    })
  }
}

#Preview {
  LocationDeniedView()
}
