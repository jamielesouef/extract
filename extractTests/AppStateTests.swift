//
//  AppStateTests.swift
//  extractTests
//
//  Created by Jamie Le Souef on 3/9/2025.
//

import Testing
import SwiftUI
@testable import extract

@Suite("AppState Tests")
struct AppStateTests {
    
    @Test("AppState initializes with correct default values")
    @MainActor
    func testAppStateInitialization() async {
        let appState = AppState()
        
        #expect(appState.path.isEmpty)
        #expect(appState.windowSize == .zero)
    }
    
    @Test("Navigation path can be modified")
    @MainActor
    func testNavigationPathModification() async {
        let appState = AppState()
        
        // Initially empty
        #expect(appState.path.isEmpty)
        
        // Add navigation option
        appState.path.append(NavigationOptions.newPhotos)
        #expect(appState.path.count == 1)
        
        // Clear path by recreating it
        appState.path = NavigationPath()
        #expect(appState.path.isEmpty)
    }
    
    @Test("Window size can be updated")
    @MainActor
    func testWindowSizeUpdate() async {
        let appState = AppState()
        
        // Initially zero
        #expect(appState.windowSize == .zero)
        
        // Update size
        let newSize = CGSize(width: 800, height: 600)
        appState.windowSize = newSize
        #expect(appState.windowSize == newSize)
    }
}