//
//  SelectionContaining.swift
//  extract
//
//  Created by Jamie Le Souef on 10/9/2025.
//

import SwiftUI

protocol SelectionContaining {
  func select(_ asset: MediaAsset)
  func select(_ assets: [MediaAsset])
  func deselect(_ asset: MediaAsset)
  func deselect(_ assets: [MediaAsset])
}

@Observable
final class SelectionContainer: SelectionContaining {
  private(set) var selected: [MediaAsset] = []
  private var selectedIds: Set<String> = []

  func select(_ asset: MediaAsset) {
    select([asset])
  }

  func select(_ assets: [MediaAsset]) {
    for asset in assets {
      if !selectedIds.contains(asset.id) {
        selectedIds.insert(asset.id)
        selected.append(asset)
      }
    }
  }

  func deselect(_ asset: MediaAsset) {
    deselect([asset])
  }

  func deselect(_ assets: [MediaAsset]) {
    for asset in assets {
      if selectedIds.contains(asset.id) {
        selectedIds.remove(asset.id)
        selected.removeAll { $0.id == asset.id }
      }
    }
  }
}
