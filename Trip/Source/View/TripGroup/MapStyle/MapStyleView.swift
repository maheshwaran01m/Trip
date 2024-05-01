//
//  MapStyleView.swift
//  Trip
//
//  Created by MAHESHWARAN on 21/04/24.
//

import SwiftUI

struct MapStyleView: View {
  
  @SwiftUI.Environment(\.dismiss) private var dismiss
  
  @Binding var mapStyle: MapStyleConfiguration

  var body: some View {
    NavigationStack {
      
      VStack(alignment: .leading) {
        
        LabeledContent("Base Style") {
          Picker("Style", selection: $mapStyle.baseStyle) {
            
            ForEach(MapStyleConfiguration.Style.allCases,
                    id: \.self) { row in
              Text(row.label)
            }
          }
        }
        
        LabeledContent("Elevation") {
          Picker("Style", selection: $mapStyle.elevation) {
            
            Text("Flat")
              .tag(MapStyleConfiguration.Elevation.flat)
            
            Text("Realistic")
              .tag(MapStyleConfiguration.Elevation.realistic)
          }
        }
        
        if mapStyle.baseStyle != .imagery {
          
          LabeledContent("Points of Interest") {
            Picker("Style", selection: $mapStyle.pointsOfInterest) {
              
              Text("None")
                .tag(MapStyleConfiguration.MapPOI.excludingAll)
              
              Text("All")
                .tag(MapStyleConfiguration.MapPOI.all)
            }
          }
          
          Toggle("Show Traffic", isOn: $mapStyle.showTraffic)
        }
        
        Button("Ok") {
          dismiss()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .buttonStyle(.borderedProminent)
      }
      .padding()
      .navigationTitle("Map Style")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

#Preview {
  MapStyleView(mapStyle: .constant(.init()))
}
