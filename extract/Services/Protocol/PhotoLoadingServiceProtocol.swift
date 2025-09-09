//
//  PhotoLoadingServiceProtocol.swift
//  extract
//
//  Created by Jamie Le Souef on 9/9/2025.
//

import Photos
import SwiftUI

protocol MediaStoring: Sendable {
  var items: [PHAsset] { get set }
  var authorizationStatus: Bool? { get set }
  var isLoading: Bool { get set }
  var count: Int { get }
  var photosCount: Int { get set }
  var videoCount: Int { get set }

  func requestAccess() async
  func loadAllAssets() async
  func requestAndLoad() async
  func getCloudIdentifier(for asset: PHAsset) async -> String?
}
