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
  func deselect(_ asset: PHAsset)
}

final class SelectionContainer: SelectionContaining {
  private(set) var selected: Set<PHAsset> = []

  func select(_ asset: PHAsset) {
    selected.insert(asset)
  }

  func deselect(_ asset: PHAsset) {
    selected.remove(asset)
  }
}
