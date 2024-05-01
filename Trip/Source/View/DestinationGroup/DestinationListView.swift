//
//  DestinationListView.swift
//  Trip
//
//  Created by MAHESHWARAN on 21/04/24.
//

import SwiftUI
import SwiftData

struct DestinationListView: View {
  
  @Query(sort: \Destination.name) private var destinations: [Destination]
  @Environment(\.modelContext) private var modelContext
  
  @State private var isNewDestination = false
  @State private var destinationTitle = ""
  
  @State private var path = NavigationPath()

  
  var body: some View {
    NavigationStack(path: $path) {
      mainView
    }
  }
  
  // MARK: - List
  
  @ViewBuilder
  private var mainView: some View {
    Group {
      if !destinations.isEmpty {
        detailView
      } else {
        placeholderView
      }
    }
    .toolbar(content: addButton)
    .navigationTitle("Destination")
  }
  
  private var detailView: some View {
    List(destinations) { destination in
      
      NavigationLink(value: destination) {
        HStack(alignment: .top) {
          Image(systemName: "globe")
            .imageScale(.large)
            .foregroundStyle(.accent)
          
          VStack(alignment: .leading) {
            Text(destination.name)
            
            Text("^[\(destination.placemarks.count) location](inflect: true)")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
        .swipeActions(edge: .trailing) { deleteButton(destination) }
      }
    }
    .navigationDestination(for: Destination.self) { destination in
      DestinationLocationView(for: destination)
    }
  }
  
  // MARK: - Placeholder
  
  private var placeholderView: some View {
    ContentUnavailableView(
      "No Destinations",
      systemImage: "globe.desk",
      description: Text("You have not set up any destinations, \n Tap on the \(Image(systemName: "plus")) button in the toolbar to create destinations"))
  }
  
  // MARK: - Add Button
  
  @ToolbarContentBuilder
  private func addButton() -> some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button {
        isNewDestination.toggle()
      } label: {
        Image(systemName: "plus")
      }
      .alert("New Destination",
             isPresented: $isNewDestination) {
        TextField("Enter Destination Title", text: $destinationTitle)
          .autocorrectionDisabled()
        
        Button("Ok") {
          guard !destinationTitle.isEmpty else { return }
          
          let destination = Destination(name: destinationTitle.trimmingCharacters(in: .whitespacesAndNewlines))
          modelContext.insert(destination)
          
          destinationTitle = ""
          
          path.append(destination)
        }
        
        Button("Cancel", role: .cancel) { }
      } message: {
        Text("Create a new Destination")
      }
    }
  }
  
  // MARK: - Delete Button
  
  private func deleteButton(_ destination: Destination) -> some View {
    Button(role: .destructive) {
      modelContext.delete(destination)
    } label: {
      Label("Delete", systemImage: "trash")
    }
  }
}

// MARK: - Preview

#Preview {
  DestinationListView()
    .modelContainer(Destination.preview)
}
