//
//  SelectionService.swift
//  extract
//
//  Created by Jamie Le Souef on 10/9/2025.
//

import Photos
import SwiftUI

protocol SelectionServicing {
  associatedtype T
  func select(_ asset: T)
  func deselect(_ asset: T)
}

final class SelectionService<T: Hashable & PhotoAsset>: SelectionServicing {
  private var selected: Set<T> = []

  func select(_ asset: T) {
    selected.insert(asset)
  }

  func deselect(_ asset: T) {
    selected.remove(asset)
  }
}
