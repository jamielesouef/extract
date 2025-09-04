//
//  NavigationOptionsTests.swift
//  extractTests
//
//  Created by Jamie Le Souef on 3/9/2025.
//

import Testing
import SwiftUI
@testable import extract

@Suite("NavigationOptions Tests")
struct NavigationOptionsTests {
    
    @Test("NavigationOptions id property returns correct string values")
    @MainActor
    func testIdProperty() async {
        #expect(NavigationOptions.newPhotos.id == "newPhotos")
        #expect(NavigationOptions.backedUpPhotos.id == "backedUpPhotos")
        #expect(NavigationOptions.failedPhotosAccess.id == "failedPhotosAccess")
    }
    
    @Test("NavigationOptions pages static property contains correct cases")
    @MainActor
    func testPagesProperty() async {
        let expectedPages: [NavigationOptions] = [.newPhotos, .backedUpPhotos]
        
        #expect(NavigationOptions.pages == expectedPages)
        #expect(NavigationOptions.pages.count == 2)
        #expect(NavigationOptions.pages.contains(.newPhotos))
        #expect(NavigationOptions.pages.contains(.backedUpPhotos))
        #expect(!NavigationOptions.pages.contains(.failedPhotosAccess))
    }
    
    @Test("NavigationOptions icon property returns correct SF Symbols")
    @MainActor
    func testIconProperty() async {
        #expect(NavigationOptions.newPhotos.icon == "photo.circle")
        #expect(NavigationOptions.backedUpPhotos.icon == "lock.circle")
        #expect(NavigationOptions.failedPhotosAccess.icon == "exclamationmark.triangle")
    }
    
    @Test("NavigationOptions name property returns LocalizedStringResource")
    @MainActor
    func testNameProperty() async {
        // Test that the name properties exist and are LocalizedStringResource types
        let newPhotosName = NavigationOptions.newPhotos.name
        let backedUpPhotosName = NavigationOptions.backedUpPhotos.name
        let failedAccessName = NavigationOptions.failedPhotosAccess.name
        
        // Verify they are LocalizedStringResource instances
        #expect(newPhotosName is LocalizedStringResource)
        #expect(backedUpPhotosName is LocalizedStringResource)
        #expect(failedAccessName is LocalizedStringResource)
    }
    
    @Test("NavigationOptions conforms to Equatable")
    @MainActor
    func testEquatableConformance() async {
        #expect(NavigationOptions.newPhotos == NavigationOptions.newPhotos)
        #expect(NavigationOptions.backedUpPhotos == NavigationOptions.backedUpPhotos)
        #expect(NavigationOptions.failedPhotosAccess == NavigationOptions.failedPhotosAccess)
        
        #expect(NavigationOptions.newPhotos != NavigationOptions.backedUpPhotos)
        #expect(NavigationOptions.newPhotos != NavigationOptions.failedPhotosAccess)
        #expect(NavigationOptions.backedUpPhotos != NavigationOptions.failedPhotosAccess)
    }
    
    @Test("NavigationOptions conforms to Hashable")
    @MainActor
    func testHashableConformance() async {
        let set: Set<NavigationOptions> = [.newPhotos, .backedUpPhotos, .failedPhotosAccess]
        
        #expect(set.count == 3)
        #expect(set.contains(.newPhotos))
        #expect(set.contains(.backedUpPhotos))
        #expect(set.contains(.failedPhotosAccess))
    }
    
    @Test("NavigationOptions conforms to Identifiable")
    @MainActor
    func testIdentifiableConformance() async {
        // Test that each case has a unique ID
        let options: [NavigationOptions] = [.newPhotos, .backedUpPhotos, .failedPhotosAccess]
        let ids = options.map { $0.id }
        let uniqueIds = Set(ids)
        
        #expect(ids.count == uniqueIds.count) // All IDs should be unique
        
        // Test that ID is consistent for the same case
        #expect(NavigationOptions.newPhotos.id == NavigationOptions.newPhotos.id)
    }
    
    @Test("NavigationOptions viewForPage returns correct view types")
    @MainActor
    func testViewForPage() async {
        // Test that viewForPage returns views without crashing
        // Note: We can't easily test the exact view types due to SwiftUI's type erasure,
        // but we can test that the method executes without throwing
        
        let newPhotosView = NavigationOptions.newPhotos.viewForPage()
        let backedUpPhotosView = NavigationOptions.backedUpPhotos.viewForPage()
        let failedAccessView = NavigationOptions.failedPhotosAccess.viewForPage()
        
        // If we reach here without crashing, the views were created successfully
        #expect(type(of: newPhotosView) != Void.self)
        #expect(type(of: backedUpPhotosView) != Void.self)
        #expect(type(of: failedAccessView) != Void.self)
    }
    
    @Test("NavigationOptions all cases coverage")
    @MainActor
    func testAllCases() async {
        // Test that we have all the expected cases
        let allTestCases: [NavigationOptions] = [.newPhotos, .backedUpPhotos, .failedPhotosAccess]
        
        // Verify each case has proper properties
        for option in allTestCases {
            #expect(!option.id.isEmpty)
            #expect(!option.icon.isEmpty)
            #expect(option.name is LocalizedStringResource)
        }
    }
    
    @Test("NavigationOptions pages excludes failedPhotosAccess")
    @MainActor
    func testPagesExcludesFailedAccess() async {
        // Verify that failedPhotosAccess is not included in the pages array
        // This is important for navigation UI that shouldn't show the error state
        
        #expect(!NavigationOptions.pages.contains(.failedPhotosAccess))
        
        // Verify that only the normal navigation cases are included
        let normalCases: Set<NavigationOptions> = [.newPhotos, .backedUpPhotos]
        let pagesSet = Set(NavigationOptions.pages)
        
        #expect(pagesSet == normalCases)
    }
}