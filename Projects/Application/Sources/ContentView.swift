import SwiftUI
import ComposableArchitecture
import PresentationKit
import FoundationKit

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // App Logo and Title
                VStack(spacing: 16) {
                    Image(systemName: "app.badge.checkmark")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("SpotifyStats")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                // Module Overview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Architecture Modules")
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    ModuleCard(title: "FoundationKit", description: "Core utilities and extensions", icon: "hammer.fill")
                    ModuleCard(title: "DIKit", description: "Dependency injection with Swinject", icon: "arrow.triangle.branch")
                    ModuleCard(title: "DomainKit", description: "Business logic and domain models", icon: "brain.head.profile")
                    ModuleCard(title: "DataKit", description: "Data layer with Alamofire", icon: "externaldrive.fill")
                    ModuleCard(title: "PresentationKit", description: "UI components with TCA", icon: "paintbrush.fill")
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("SpotifyStats")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ModuleCard: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    ContentView()
}
