//
//  SelectionContaining.swift
//  extract
//
//  Created by Jamie Le Souef on 10/9/2025.
//

import Photos
import SwiftUI

protocol SelectionContaining {
  func select(_ asset: PHAsset)
  func select(_ asset: [PHAsset])
  func deselect(_ asset: PHAsset)
  func deselect(_ asset: [PHAsset])
}

@Observable
final class SelectionContainer: SelectionContaining {
  private(set) var selected: [PHAsset] = []
  private var assetToIdentifier: [ObjectIdentifier: String] = [:]

  func select(_ asset: PHAsset) {
    select([asset])
  }

  func select(_ asset: [PHAsset]) {
    for item in asset {
      // Use object identifier for uniqueness since localIdentifier might be empty
      let objId = ObjectIdentifier(item)
      if !assetToIdentifier.keys.contains(objId) {
        let identifier = item.localIdentifier.isEmpty ? UUID().uuidString : item.localIdentifier
        assetToIdentifier[objId] = identifier
        selected.append(item)
      }
    }
  }

  func deselect(_ asset: PHAsset) {
    deselect([asset])
  }

  func deselect(_ asset: [PHAsset]) {
    for item in asset {
      let objId = ObjectIdentifier(item)
      if let index = selected.firstIndex(where: { ObjectIdentifier($0) == objId }) {
        selected.remove(at: index)
        assetToIdentifier.removeValue(forKey: objId)
      }
    }
  }
}
