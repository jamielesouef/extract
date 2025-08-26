//
//  AppState.swift
//  extract
//
//  Created by Jamie Le Souef on 26/8/2025.
//

import Foundation
import SwiftUI

@Observable @MainActor
final class AppState {
  var pathStack: NavigationPath = .init()
  var windowSize: CGSize = .zero
}
