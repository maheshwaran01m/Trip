//
//  LocationDetailView.swift
//  Trip
//
//  Created by MAHESHWARAN on 21/04/24.
//

import SwiftUI
import MapKit
import SwiftData

struct LocationDetailView: View {
  
  @SwiftUI.Environment(\.dismiss) private var dismiss
  
  var destination: Destination?
  var selectedPlacemark: MTPlacemark?
  
  @State private var name = ""
  @State private var address = ""
  
  var isChanged: Bool {
    guard let selectedPlacemark else { return false }
    
    return name != selectedPlacemark.name || address != selectedPlacemark.address
  }

  var body: some View {
    Text("Hello, World!")
  }
}

// MARK: - Preview

#Preview {
  let container = Destination.preview
  let fetch = FetchDescriptor<Destination>()
  
  let destinations = try! container.mainContext.fetch(fetch)
  let selectedPlacemark = destinations[0]
  
  return NavigationStack {
    LocationDetailView()
  }
  .modelContainer(Destination.preview)
}
